# Utilisez l'image officielle Python
FROM python:3.13.0-alpine3.20

# Créez un répertoire dans le conteneur pour l'application
WORKDIR /app

# Copiez le script sum.py dans le répertoire /app
COPY sum.py /app/sum.py

# Assurez-vous que le conteneur reste actif en lançant un shell interactif
CMD ["tail", "-f", "/dev/null"]