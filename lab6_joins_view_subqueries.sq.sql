
-- Étape 1 – Connexion et contexte
USE bibliotheque;

-- Étape 2 – Jointures classiques

-- 1 INNER JOIN : ne conserver que les lignes présentes dans les deux tables
SELECT e.id AS emprunt_id, a.nom AS abonne_nom, e.date_debut, e.date_fin
FROM emprunt e
INNER JOIN abonne a ON e.abonne_id = a.id;

-- 2.LEFT JOIN : inclure tous les enregistrements de la table de gauche
SELECT o.id, o.titre, MAX(e.date_debut) AS dernier_emprunt
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
GROUP BY o.id, o.titre;

-- 4 CROSS JOIN : produit cartésien

SELECT a.nom AS abonne_nom, au.nom AS auteur_nom
FROM abonne a
CROSS JOIN auteur au
LIMIT 20; 

-- Étape 3 – Création et utilisation de vues

-- 1 Créer une vue
CREATE OR REPLACE VIEW vue_emprunts_par_abonne AS
SELECT a.id, a.nom, COUNT(e.id) AS total_emprunts
FROM abonne a
LEFT JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom;

-- 2 Interroger la vue
SELECT * 
FROM vue_emprunts_par_abonne 
WHERE total_emprunts > 5;

-- 3 Modifier et supprimer une vue
DROP VIEW IF EXISTS vue_emprunts_par_abonne;

-- Étape 4 – Sous-requêtes non corrélées

-- 1 Sous-requête dans SELECT
SELECT 
    o.titre,
    (SELECT COUNT(*)
     FROM emprunt e
     WHERE e.ouvrage_id = o.id) AS nb_emprunts
FROM ouvrage o;

-- 2 Sous-requête dans WHERE
SELECT nom, email
FROM abonne
WHERE id IN (
    SELECT abonne_id
    FROM emprunt
    GROUP BY abonne_id
    HAVING COUNT(*) > 3
);


-- Étape 5 – Sous-requêtes corrélées

-- 5.1
SELECT 
    a.nom,
    (SELECT o.titre
     FROM emprunt e2
     JOIN ouvrage o ON e2.ouvrage_id = o.id
     WHERE e2.abonne_id = a.id
     ORDER BY e2.date_debut ASC
     LIMIT 1) AS premier_titre
FROM abonne a;

-- Étape 6 – Combiner vues et sous-requêtes

-- 1 Créer une vue résumant les emprunts par mois :
CREATE OR REPLACE VIEW vue_emprunts_mensuels AS
SELECT 
    YEAR(date_debut) AS annee,
    MONTH(date_debut) AS mois,
    COUNT(*) AS total_emprunts
FROM emprunt
GROUP BY annee, mois;

-- 2 Utiliser cette vue dans une sous-requête pour extraire les mois les plus chargés :
SELECT v.annee, v.mois, v.total_emprunts
FROM vue_emprunts_mensuels v
WHERE v.total_emprunts = (
    SELECT MAX(total_emprunts)
    FROM vue_emprunts_mensuels
    WHERE annee = v.annee
);


-- Étape 7 – Exercices pratiques

-- Exercice 1 : écrire une requête listant tous les auteurs sans ouvrage, en utilisant un LEFT JOIN et la clause IS NULL.
SELECT au.id, au.nom AS auteur_nom
FROM auteur au
LEFT JOIN ouvrage o ON au.id = o.auteur_id
WHERE o.id IS NULL;

-- Exercice 2 : créer une vue qui affiche, pour chaque mois, le nombre d’abonnés qui ont emprunté au moins une fois.
CREATE OR REPLACE VIEW vue_abonnes_actifs_mensuels AS
SELECT 
    YEAR(date_debut) AS annee,
    MONTH(date_debut) AS mois,
    COUNT(DISTINCT abonne_id) AS abonnes_actifs
FROM emprunt
GROUP BY annee, mois;

--
SELECT * FROM vue_abonnes_actifs_mensuels ORDER BY annee, mois;

-- Exercice 3 : utiliser une sous-requête corrélée pour trouver, pour chaque ouvrage, l’abonné qui l’a emprunté le plus récemment.
SELECT 
    o.titre,
    (SELECT a.nom
     FROM emprunt e2
     JOIN abonne a ON e2.abonne_id = a.id
     WHERE e2.ouvrage_id = o.id
     ORDER BY e2.date_debut DESC
     LIMIT 1) AS dernier_emprunteur
FROM ouvrage o
WHERE EXISTS (
    SELECT 1
    FROM emprunt e3
    WHERE e3.ouvrage_id = o.id
);

-- List FOR  ALL THE VIEWS  CREATED 
SHOW FULL TABLES IN bibliotheque WHERE TABLE_TYPE LIKE 'VIEW';
