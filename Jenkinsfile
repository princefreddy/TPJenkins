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
                    def cmd = "docker run -d ${DOCKER_IMAGE}"
                    def output = bat(script: cmd, returnStdout: true).trim()
                    // Récupérer la dernière ligne non vide
                    def containerID = output.readLines().findAll { it.trim() }.last()
                    
                    // Vérifier si l'ID est valide
                    if (containerID ==~ /[a-f0-9]{12,}/) {
                        // Stocker l'ID dans un fichier
                        writeFile file: 'container_id.txt', text: containerID
                        // Lire le fichier immédiatement pour vérifier
                        env.CONTAINER_ID = readFile('container_id.txt').trim()
                        
                        echo "Container ID stocké: ${env.CONTAINER_ID}"
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
                    // Lire l'ID du conteneur depuis le fichier
                    env.CONTAINER_ID = readFile('container_id.txt').trim()
                    echo "Container ID lu: ${env.CONTAINER_ID}"
                    
                    if (!env.CONTAINER_ID?.trim()) {
                        error "ID du conteneur non trouvé"
                    }
                    
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    // ... reste du code de test inchangé ...
                }
            }
        }
        
        // ... autres stages inchangés ...
    }
    
    post {
        always {
            script {
                echo "Début du nettoyage"
                try {
                    // Lire l'ID du conteneur depuis le fichier
                    env.CONTAINER_ID = readFile('container_id.txt').trim()
                    if (env.CONTAINER_ID?.trim()) {
                        bat "docker stop ${env.CONTAINER_ID}"
                        bat "docker rm ${env.CONTAINER_ID}"
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