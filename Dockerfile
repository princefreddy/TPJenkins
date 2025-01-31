FROM python:3.13.0-alpine3.20

# Création du répertoire de travail
WORKDIR /app

# Copie du script Python dans le conteneur
COPY sum.py /app/

# Commande pour garder le conteneur actif
CMD ["tail", "-f", "/dev/null"]