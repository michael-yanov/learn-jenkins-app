pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '1e510cfc-5f2f-424e-99cb-bec56cbe272d'
        NETLIFY_AUTH_TOKEN = credentials('netlify_token')
    }

    options {
        buildDiscarder (
            logRotator (
                numToKeepStr: '10'
            )
        )
    }

    stages {

        stage ('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                }
                steps {
                    sh '''
                        aws --version
                    '''
                }
        }

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    set -e
                    node --version
                    npm --version

                    npm cache clean --force

                    npm install
                    npm run build
                '''
            }
        }

        stage ('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            [ -f build/index.html ]
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }      
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. project ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }

    }
}
