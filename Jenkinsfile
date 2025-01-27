pipeline {
    agent any

    environment {
        CONTAINER_ID = '' // Variable pour stocker l'ID du conteneur
        SUM_PY_PATH = '/sum.py' // Chemin vers le fichier sum.py
        DIR_PATH = '/' // Chemin vers le répertoire contenant le Dockerfile
        TEST_FILE_PATH = '/test_variables.txt' // Chemin vers le fichier de test
        DOCKER_IMAGE_NAME = 'jenkins-image' // Nom de l'image Docker
        DOCKERHUB_REPO = 'princefreddy/jenkins-image' // Nom du dépôt DockerHub
    }

    stages {
        // Étape 1: Construction de l'image Docker
        stage('Build') {
            steps {
                script {
                    echo "Construction de l'image Docker..."
                    sh "docker build -t ${DOCKER_IMAGE_NAME} ${DIR_PATH}"
                }
            }
        }

        // Étape 2: Exécution du conteneur Docker
        stage('Run') {
            steps {
                script {
                    echo "Exécution du conteneur Docker..."
                    def output = sh(
                        script: "docker run -d ${DOCKER_IMAGE_NAME} tail -f /dev/null",
                        returnStdout: true
                    ).trim()
                    CONTAINER_ID = output
                    echo "Conteneur démarré avec l'ID : ${CONTAINER_ID}"
                }
            }
        }

        // Étape 3: Test du script Python
        stage('Test') {
            steps {
                script {
                    echo "Exécution des tests avec le fichier ${TEST_FILE_PATH}..."
                    def testLines = readFile(TEST_FILE_PATH).split('\n')

                    for (line in testLines) {
                        if (line.trim()) { // Ignorer les lignes vides
                            def vars = line.split(' ')
                            def arg1 = vars[0]
                            def arg2 = vars[1]
                            def expectedSum = vars[2].toFloat()

                            def output = sh(
                                script: "docker exec ${CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}",
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

        // Étape 4: Déploiement sur DockerHub
        stage('Deploy to DockerHub') {
            steps {
                script {
                    echo "Déploiement de l'image Docker sur DockerHub..."
                    sh "docker login -u princefreddy -p @Princefreddy15"
                    sh "docker tag ${DOCKER_IMAGE_NAME} ${DOCKERHUB_REPO}"
                    sh "docker push ${DOCKERHUB_REPO}"
                    echo "Image poussée avec succès sur DockerHub."
                }
            }
        }
    }

    // Étape 5: Nettoyage après le pipeline
    post {
        always {
            script {
                echo "Nettoyage du conteneur Docker..."
                sh "docker stop ${CONTAINER_ID} || true"
                sh "docker rm ${CONTAINER_ID} || true"
            }
        }
    }
}
