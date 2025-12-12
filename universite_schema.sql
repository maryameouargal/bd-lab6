
-- Exercise 1:

-- A. Création du schéma:

-- A.1 Create database
CREATE DATABASE IF NOT EXISTS UNIVERSITE 
CHARACTER SET UTF8MB4 
COLLATE UTF8MB4_UNICODE_CI;

USE UNIVERSITE;

-- A.2 Create tables with proper constraints

-- 1. ETUDIANT table
CREATE TABLE ETUDIANT (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;

-- 2. PROFESSEUR table
CREATE TABLE PROFESSEUR (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;

-- 3. COURS table
CREATE TABLE COURS (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;

-- 4. ENSEIGNEMENT table
CREATE TABLE ENSEIGNEMENT (
    id INT PRIMARY KEY AUTO_INCREMENT,
    professeur_id INT,
    cours_id INT NOT NULL,
    semestre VARCHAR(20) NOT NULL,
    annee INT NOT NULL,
    FOREIGN KEY (professeur_id) REFERENCES PROFESSEUR(id) ON DELETE SET NULL,
    FOREIGN KEY (cours_id) REFERENCES COURS(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enseignement (cours_id, semestre, annee)
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;

-- 5. INSCRIPTION table
CREATE TABLE INSCRIPTION (
    etudiant_id INT NOT NULL,
    enseignement_id INT NOT NULL,
    date_inscription DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (etudiant_id, enseignement_id),
    FOREIGN KEY (etudiant_id) REFERENCES ETUDIANT(id) ON DELETE CASCADE,
    FOREIGN KEY (enseignement_id) REFERENCES ENSEIGNEMENT(id) ON DELETE CASCADE
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;

-- 6. EXAMEN table
CREATE TABLE EXAMEN (
    id INT PRIMARY KEY AUTO_INCREMENT,
    etudiant_id INT NOT NULL,
    enseignement_id INT NOT NULL,
    date_examen DATE DEFAULT (CURRENT_DATE),
    score DECIMAL(4,2) CHECK (score BETWEEN 0 AND 20),
    FOREIGN KEY (etudiant_id, enseignement_id) 
        REFERENCES INSCRIPTION(etudiant_id, enseignement_id),
    INDEX idx_date_examen (date_examen)
) ENGINE=InnoDB 
  CHARACTER SET UTF8MB4 
  COLLATE UTF8MB4_UNICODE_CI;


-- B. Contraintes supplémentaires (question 5)

-- La contrainte pour empêcher les doublons est déjà gérée par:
-- PRIMARY KEY (etudiant_id, enseignement_id) dans INSCRIPTION
-- Cela empêche un étudiant de s'inscrire deux fois au même enseignement


-- C. Insertion et tests :
-- C.7 Insérer des données de test

-- 2 professeurs
INSERT INTO PROFESSEUR (nom, email, department) VALUES 
('Dr. Martin Dupont', 'martin.dupont@universite.fr', 'informatique'),
('Prof. Sophie Bernard', 'sophie.bernard@universite.fr', 'mathematiques');

-- 3 cours
INSERT INTO COURS (titre, code, credits) VALUES
('Introduction à la programmation', 'CS101', 3),
('Systèmes de bases de données', 'CS201', 4),
('Calcul différentiel', 'MATH101', 4);

-- 2 étudiants (corrigé de FINDIANT à ETUDIANT)
INSERT INTO ETUDIANT (nom, email) VALUES
('Alice Martin', 'alice.martin@etudiant.universite.fr'),
('Bob Wilson', 'bob.wilson@etudiant.universite.fr');

-- 2 enseignements
INSERT INTO ENSEIGNEMENT (professeur_id, cours_id, semestre, annee) VALUES
(1, 1, 'Automne', 2024),  -- Dr. Dupont enseigne CS101
(2, 3, 'Automne', 2024);  -- Prof. Bernard enseigne MATH101

-- 4 inscriptions
INSERT INTO INSCRIPTION (etudiant_id, enseignement_id, date_inscription) VALUES
(1, 1, '2024-09-01'),  -- Alice s'inscrit à CS101
(1, 2, '2024-09-01'),  -- Alice s'inscrit à MATH101
(2, 1, '2024-09-02'),  -- Bob s'inscrit à CS101
(2, 2, '2024-09-03');  -- Bob s'inscrit à MATH101

-- C.8 Tester la contrainte CHECK avec un score invalide (25)
INSERT INTO EXAMEN (etudiant_id, enseignement_id, score) VALUES (1, 1, 25);

-- C.9 Insérer des examens valides
INSERT INTO EXAMEN (etudiant_id, enseignement_id, score, date_examen) VALUES
(1, 1, 18.5, '2024-12-15'),
(1, 2, 16.0, '2024-12-16'),
(2, 1, 14.5, '2024-12-15'),
(2, 2, 19.0, '2024-12-16');


-- D. Sélection et filtrage
-- D.10 Lister tous les étudiants inscrits au cours dont code='CS101':
SELECT DISTINCT e.nom, e.email
FROM ETUDIANT e
JOIN INSCRIPTION i ON e.id = i.etudiant_id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
JOIN COURS c ON ens.cours_id = c.id
WHERE c.code = 'CS101';

-- D.11 Afficher le nom et l'email de chaque professeur du département « informatique »
SELECT nom, email
FROM PROFESSEUR
WHERE department = 'informatique';

-- D.12 Récupérer les inscriptions de l'étudiant « Alice » triées par date_inscription décroissante
SELECT i.*, c.titre AS cours_titre
FROM INSCRIPTION i
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
JOIN COURS c ON ens.cours_id = c.id
JOIN ETUDIANT e ON i.etudiant_id = e.id
WHERE e.nom LIKE '%Alice%'
ORDER BY i.date_inscription DESC;


-- E. Jointures et sous-requêtes
-- E.13 Pour chaque inscription afficher : nom étudiant, titre cours, semestre, date inscription
SELECT 
    e.nom AS etudiant_nom,
    c.titre AS cours_titre,
    ens.semestre,
    i.date_inscription
FROM INSCRIPTION i
JOIN ETUDIANT e ON i.etudiant_id = e.id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
JOIN COURS c ON ens.cours_id = c.id
ORDER BY i.date_inscription;

-- E.14 Pour chaque étudiant, le nombre total de cours auxquels il est inscrit (sous-requête corrélée)
SELECT 
    e.nom,
    e.email,
    (SELECT COUNT(*) 
     FROM INSCRIPTION i 
     WHERE i.etudiant_id = e.id) AS nombre_cours_inscrits
FROM ETUDIANT e
ORDER BY nombre_cours_inscrits DESC;

-- E.15 Créer la vue vue_étudiant_charges
CREATE OR REPLACE VIEW vue_etudiant_charges AS
SELECT 
    e.id AS etudiant_id,
    e.nom AS etudiant_nom,
    COUNT(DISTINCT i.enseignement_id) AS nombre_inscriptions,
    SUM(c.credits) AS total_credits
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON e.id = i.etudiant_id
LEFT JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
LEFT JOIN COURS c ON ens.cours_id = c.id
GROUP BY e.id, e.nom;

-- Tester la vue
SELECT * FROM vue_etudiant_charges;

-- F. Agrégation et rapports
-- F.16 Pour chaque cours, calculer le nombre d'inscriptions
SELECT 
    c.code,
    c.titre,
    COUNT(i.etudiant_id) AS nombre_inscriptions
FROM COURS c
LEFT JOIN ENSEIGNEMENT ens ON c.id = ens.cours_id
LEFT JOIN INSCRIPTION i ON ens.id = i.enseignement_id
GROUP BY c.id, c.code, c.titre
ORDER BY nombre_inscriptions DESC;

-- F.17 Lister les cours qui ont reçu plus de 10 inscriptions (exemple avec données actuelles)
-- Note: Avec nos données de test, aucun cours n'a plus de 10 inscriptions
SELECT 
    c.code,
    c.titre,
    COUNT(i.etudiant_id) AS nombre_inscriptions
FROM COURS c
JOIN ENSEIGNEMENT ens ON c.id = ens.cours_id
JOIN INSCRIPTION i ON ens.id = i.enseignement_id
GROUP BY c.id, c.code, c.titre
HAVING COUNT(i.etudiant_id) > 10;

-- F.18 Pour chaque semestre, la moyenne des scores d'examen arrondie à deux décimales
SELECT 
    ens.semestre,
    ens.annee,
    ROUND(AVG(ex.score), 2) AS moyenne_scores
FROM EXAMEN ex
JOIN INSCRIPTION i ON ex.etudiant_id = i.etudiant_id 
                   AND ex.enseignement_id = i.enseignement_id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
GROUP BY ens.semestre, ens.annee
ORDER BY ens.annee DESC, ens.semestre;

-- G. Maintenance du schéma
-- G.19 Ajouter une colonne commentaire TEXT à EXAMEN
ALTER TABLE EXAMEN 
ADD COLUMN commentaire TEXT 
AFTER score;

-- G.20 Exemple de modification supplémentaire : ajouter un index
ALTER TABLE EXAMEN 
ADD INDEX idx_score (score);

-- Vérifier la structure mise à jour
DESCRIBE EXAMEN;


-- vérifications finales
-- Lister toutes les tables créées
SHOW TABLES;

-- Voir la structure de chaque table
SHOW CREATE TABLE ETUDIANT;
SHOW CREATE TABLE PROFESSEUR;
SHOW CREATE TABLE COURS;
SHOW CREATE TABLE ENSEIGNEMENT;
SHOW CREATE TABLE INSCRIPTION;
SHOW CREATE TABLE EXAMEN;

-- Vérifier les données insérées
SELECT 'ETUDIANT' AS table_name, COUNT(*) AS row_count FROM ETUDIANT
UNION ALL
SELECT 'PROFESSEUR', COUNT(*) FROM PROFESSEUR
UNION ALL
SELECT 'COURS', COUNT(*) FROM COURS
UNION ALL
SELECT 'ENSEIGNEMENT', COUNT(*) FROM ENSEIGNEMENT
UNION ALL
SELECT 'INSCRIPTION', COUNT(*) FROM INSCRIPTION
UNION ALL
SELECT 'EXAMEN', COUNT(*) FROM EXAMEN;