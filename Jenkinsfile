pipeline {
    agent any

    environment {
        CONTAINER_ID = '' // Variable pour stocker l'ID du conteneur
        SUM_PY_PATH = './sum.py' // Chemin vers le fichier sum.py
        DIR_PATH = './' // Chemin vers le répertoire contenant le Dockerfile
        TEST_FILE_PATH = './test_variables.txt' // Chemin vers le fichier de test
        DOCKER_IMAGE_NAME = 'jenkins-image' // Nom de l'image Docker
        DOCKERHUB_REPO = 'princefreddy/jenkins-image' // Nom du dépôt DockerHub
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Construction de l'image Docker..."
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME} ."
                }
            }
        }

        stage('Run') {
            steps {
                script {
                    echo "Exécution du conteneur Docker..."
                    def output = sh(
                        script: "docker run -d ${env.DOCKER_IMAGE_NAME} tail -f /dev/null",
                        returnStdout: true
                    ).trim()
                    env.CONTAINER_ID = output // Assignez le conteneur à la variable globale
                    echo "Conteneur démarré avec l'ID : ${env.CONTAINER_ID}"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Exécution des tests avec le fichier ${env.TEST_FILE_PATH}..."
                    def testLines = readFile(env.TEST_FILE_PATH).split('\n')

                    for (line in testLines) {
                        if (line.trim()) {
                            def vars = line.split(' ')
                            def arg1 = vars[0]
                            def arg2 = vars[1]
                            def expectedSum = vars[2].toFloat()

                            def output = sh(
                                script: "docker exec ${env.CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}",
                                returnStdout: true
                            ).trim()

                            def result = output.toFloat()

                            if (result == expectedSum) {
                                echo "Test réussi pour ${arg1} + ${arg2} = ${result}"
                            } else {
                                error "Échec du test pour ${arg1} + ${arg2}. Attendu: ${expectedSum}, Obtenu: ${result}"
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy to DockerHub') {
            steps {
                script {
                    echo "Déploiement de l'image Docker sur DockerHub..."
                    sh "docker login -u your-dockerhub-username -p your-dockerhub-password"
                    sh "docker tag ${env.DOCKER_IMAGE_NAME} ${env.DOCKERHUB_REPO}"
                    sh "docker push ${env.DOCKERHUB_REPO}"
                    echo "Image poussée avec succès sur DockerHub."
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Nettoyage du conteneur Docker..."
                if (env.CONTAINER_ID?.trim()) { // Vérifie que CONTAINER_ID est défini et non vide
                    sh "docker stop ${env.CONTAINER_ID} || true"
                    sh "docker rm ${env.CONTAINER_ID} || true"
                } else {
                    echo "Aucun conteneur à nettoyer."
                }
            }
        }
    }
}