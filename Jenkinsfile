pipeline {
    agent any
    
    environment {
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'
        TEST_FILE_PATH = 'test_variables.txt'
        DOCKER_IMAGE = 'sum-python'
        DOCKERHUB = credentials('dockerhub')
        DOCKERHUB_REPO = 'princefreddy/sum-python'
        CONTAINER_ID = ''
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Début de la construction de l'image Docker"
                    bat "docker build -t ${DOCKER_IMAGE} ${DIR_PATH}"
                }
            }
        }
        
        stage('Run') {
            steps {
                script {
                    echo "Lancement du conteneur"
                    // Modification de la récupération de l'ID du conteneur
                    def cmd = "docker run -d ${DOCKER_IMAGE}"
                    def output = bat(script: cmd, returnStdout: true).trim()
                    // Récupérer la dernière ligne non vide
                    def containerID = output.readLines().findAll { it.trim() }.last()
                    
                    // Vérifier si l'ID est valide
                    if (containerID ==~ /[a-f0-9]{12,}/) {
                        env.CONTAINER_ID = containerID
                        echo "env.Container_ID: ${env.CONTAINER_ID}"
                        echo "containerID: ${containerID}"
                    } else {
                        echo "Impossible de récupérer l'ID du conteneur. Output: ${output}"
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Début des tests"
                    // Vérifier si le conteneur existe
                    if (!env.CONTAINER_ID?.trim()) {
                        echo "ID du conteneur non défini"
                    }
                    
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    for (line in testLines) {
                        if (!line?.trim()) continue  // Ignorer les lignes vides
                        
                        def vars = line.split(' ')
                        if (vars.length != 3) {
                            echo "Ligne de test invalide ignorée: ${line}"
                            continue
                        }
                        
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()
                        
                        def cmd = "docker exec ${env.CONTAINER_ID} python /app/sum.py ${arg1} ${arg2}"
                        def output = bat(script: cmd, returnStdout: true).trim()
                        def result = output.readLines().findAll { it.trim() }.last().toFloat()
                        
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
                    echo "Début du déploiement vers DockerHub"
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        bat """
                            echo %DOCKER_PASSWORD%| docker login -u %DOCKER_USERNAME% --password-stdin
                            docker tag ${DOCKER_IMAGE} ${DOCKERHUB_REPO}:latest
                            docker push ${DOCKERHUB_REPO}:latest
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Début du nettoyage"
                if (env.CONTAINER_ID?.trim()) {
                    try {
                        bat "docker stop ${env.CONTAINER_ID}"
                        bat "docker rm ${env.CONTAINER_ID}"
                    } catch (Exception e) {
                        echo "Erreur lors du nettoyage du conteneur: ${e.message}"
                    }
                }
                
                try {
                    bat 'docker logout'
                } catch (Exception e) {
                    echo "Erreur lors de la déconnexion de DockerHub: ${e.message}"
                }
            }
        }
        success {
            echo 'Pipeline exécuté avec succès!'
        }
        failure {
            echo 'Le pipeline a échoué.'
        }
    }
}