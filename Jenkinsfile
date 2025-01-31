pipeline {
    agent any
    
    environment {
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'
        TEST_FILE_PATH = 'test_variables.txt'
        DOCKER_IMAGE = 'sum-python'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKERHUB_REPO = 'princefreddy/sum-python'
        // On déclare CONTAINER_ID comme une variable d'environnement vide
        CONTAINER_ID = ''
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    // Construction de l'image Docker
                    bat "docker build -t ${DOCKER_IMAGE} ${DIR_PATH}"
                }
            }
        }
        
        stage('Run') {
            steps {
                script {
                    // Exécution du conteneur et stockage de son ID
                    def output = bat(script: "docker run -d ${DOCKER_IMAGE}", returnStdout: true)
                    def lines = output.split('\n')
                    // On utilise env pour définir la variable d'environnement
                    env.CONTAINER_ID = lines[-1].trim()
                    echo "Container ID: ${env.CONTAINER_ID}"
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    // Lecture du fichier de test et exécution des tests
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    for (line in testLines) {
                        def vars = line.split(' ')
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()
                        
                        // Exécution du script dans le conteneur
                        def output = bat(
                            script: "docker exec ${env.CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}",
                            returnStdout: true
                        )
                        def result = output.split('\n')[-1].trim().toFloat()
                        
                        if (result == expectedSum) {
                            echo "Test réussi pour ${arg1} + ${arg2} = ${expectedSum}"
                        } else {
                            error "Test échoué pour ${arg1} + ${arg2}. Attendu: ${expectedSum}, Obtenu: ${result}"
                        }
                    }
                }
            }
        }
        
        stage('Deploy to DockerHub') {
            steps {
                script {
                    // Connexion à DockerHub
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        bat "docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}"
                    }
                    
                    // Tag de l'image
                    bat "docker tag ${DOCKER_IMAGE} ${DOCKERHUB_REPO}:latest"
                    
                    // Push de l'image
                    bat "docker push ${DOCKERHUB_REPO}:latest"
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Vérification de l'existence d'un conteneur à nettoyer
                if (env.CONTAINER_ID?.trim()) {
                    echo "Nettoyage du conteneur ${env.CONTAINER_ID}"
                    bat "docker stop ${env.CONTAINER_ID}"
                    bat "docker rm ${env.CONTAINER_ID}"
                }
            }
        }
    }
}