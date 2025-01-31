pipeline {
    agent any
    
    environment {
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'
        TEST_FILE_PATH = 'test_variables.txt'
        DOCKER_IMAGE = 'sum-python'
        DOCKERHUB = credentials('dockerhub')
        DOCKERHUB_REPO = 'princefreddy/sum-python'
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
                    def cmd = "docker run -d ${DOCKER_IMAGE}"
                    def output = bat(script: cmd, returnStdout: true).trim()
                    // Récupérer la dernière ligne non vide
                    def containerID = output.readLines().findAll { it.trim() }.last()
                    
                    // Vérifier si l'ID est valide
                    if (containerID ==~ /[a-f0-9]{12,}/) {
                        // Stocker l'ID dans un fichier
                        writeFile file: 'container_id.txt', text: containerID
                        echo "Container ID stocké: ${containerID}"
                    } else {
                        error "Impossible de récupérer l'ID du conteneur. Output: ${output}"
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Début des tests"
                    // Lire l'ID directement depuis le fichier
                    def containerID = readFile('container_id.txt').trim()
                    echo "Container ID lu: ${containerID}"
                    
                    if (!containerID?.trim()) {
                        error "ID du conteneur non trouvé"
                    }
                    
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    for (line in testLines) {
                        if (!line?.trim()) continue
                        
                        def vars = line.split(' ')
                        if (vars.length != 3) {
                            echo "Ligne de test invalide ignorée: ${line}"
                            continue
                        }
                        
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()
                        
                        def cmd = "docker exec ${containerID} python /app/sum.py ${arg1} ${arg2}"
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
                try {
                    // Lire l'ID pour le nettoyage
                    def containerID = readFile('container_id.txt').trim()
                    if (containerID?.trim()) {
                        bat "docker stop ${containerID}"
                        bat "docker rm ${containerID}"
                    }
                } catch (Exception e) {
                    echo "Erreur lors du nettoyage du conteneur: ${e.message}"
                }
                
                try {
                    bat 'docker logout'
                } catch (Exception e) {
                    echo "Erreur lors de la déconnexion de DockerHub: ${e.message}"
                }
                
                // Nettoyer le fichier temporaire
                bat 'del container_id.txt'
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