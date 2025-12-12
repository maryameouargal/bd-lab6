
-- Exercice 2: JOINs, Views et CTEs


USE universite;
-- 1. INNER JOIN
-- Liste pour chaque examen: nom étudiant, titre cours, date examen, score
SELECT 
    e.nom AS etudiant_nom,
    c.titre AS cours_titre,
    ex.date_examen,
    ex.score
FROM EXAMEN ex
INNER JOIN ETUDIANT e ON ex.etudiant_id = e.id
INNER JOIN ENSEIGNEMENT ens ON ex.enseignement_id = ens.id
INNER JOIN COURS c ON ens.cours_id = c.id
ORDER BY ex.date_examen DESC;


-- 2. LEFT JOIN
-- Tous les étudiants avec leur nombre total d'examens (0 si aucun)
SELECT 
    e.id,
    e.nom,
    e.email,
    COUNT(ex.id) AS nombre_examens
FROM ETUDIANT e
LEFT JOIN EXAMEN ex ON e.id = ex.etudiant_id
GROUP BY e.id, e.nom, e.email
ORDER BY e.nom;

-- 3. RIGHT JOIN
-- Tous les cours avec le nombre d'étudiants inscrits (0 si aucun)
SELECT 
    c.code,
    c.titre,
    COUNT(DISTINCT i.etudiant_id) AS nombre_etudiants_inscrits
FROM INSCRIPTION i
RIGHT JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
RIGHT JOIN COURS c ON ens.cours_id = c.id
GROUP BY c.id, c.code, c.titre
ORDER BY c.code;

-- 4. CROSS JOIN
-- Toutes les paires possibles Étudiant-Professeur (limité à 20)
SELECT 
    et.nom AS etudiant_nom,
    p.nom AS professeur_nom
FROM ETUDIANT et
CROSS JOIN PROFESSEUR p
LIMIT 20;

-- Commentaire: Cette opération est coûteuse car elle génère le produit cartésien 
-- (n × m lignes) où n = nombre d'étudiants et m = nombre de professeurs.
-- Avec beaucoup de données, cela peut créer des millions de lignes inutiles.

-- 5. Création de vue vue_performances
-- Vue qui montre pour chaque étudiant sa moyenne de score
CREATE OR REPLACE VIEW vue_performances AS
SELECT 
    e.id AS etudiant_id,
    e.nom AS etudiant_nom,
    ROUND(AVG(ex.score), 2) AS moyenne_score
FROM ETUDIANT e
LEFT JOIN EXAMEN ex ON e.id = ex.etudiant_id
GROUP BY e.id, e.nom;

-- 6. Common Table Expression (CTE) - Top 3 cours
WITH top_cours AS (
    SELECT 
        c.id AS cours_id,
        c.titre,
        c.credits,
        ROUND(AVG(ex.score), 2) AS moyenne_score
    FROM COURS c
    JOIN ENSEIGNEMENT ens ON c.id = ens.cours_id
    JOIN INSCRIPTION i ON ens.id = i.enseignement_id
    JOIN EXAMEN ex ON i.etudiant_id = ex.etudiant_id 
                   AND i.enseignement_id = ex.enseignement_id
    GROUP BY c.id, c.titre, c.credits
    HAVING AVG(ex.score) IS NOT NULL
    ORDER BY moyenne_score DESC
    LIMIT 3
)
SELECT 
    titre,
    credits,
    moyenne_score
FROM top_cours
ORDER BY moyenne_score DESC;

-- Vérification de la vue
SELECT * FROM vue_performances;