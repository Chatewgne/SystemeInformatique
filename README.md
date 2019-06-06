# Projet Système Informatique

## Structure du projet

* takoyaki.l → analyse lexicale LEX
* takoyaki.y → analyse syntaxique + sémantique YACC
* instrutable.h/instrutable.c → librairie pour la table des instructions
* symboltable.h/symboltable.c →  librairie pour la table des symboles
* virtualtako.py → machine virtuelle (interpréteur) 
* input_code.c → exemple de code reconnu 
* asm.tako → fichier de sortie contenant l’assembleur généré

Notre jeu d’instruction assembleur correspond au jeu proposé par défaut pour le projet.

## Utilisation

Options de compilation du projet (rédigées dans le Makefile) : 

$ flex takoyaki.l

$ yacc -d takoyaki.y

$ gcc -o takoyaki symboltable.c instrutable.c y.tab.c lex.yy.c -ly -ll

Pour utiliser le compilateur sur un programme :

$ cat input_code.c | takoyaki
