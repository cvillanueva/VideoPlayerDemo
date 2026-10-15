pipeline {
    agent { 
        label 'ios_node' 
    }

    environment {
        // --- CONFIGURACIÓN DEL PROYECTO ---
        PROJECT_NAME = 'VideoPlayerDemo.xcodeproj'
        SCHEME_NAME  = 'VideoPlayerDemo'
        
        // --- CONFIGURACIÓN DE PRUEBAS ---
        // Define el simulador y la versión de iOS instalada en tu Mac de Jenkins
        TEST_DEVICE  = 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
        
        // --- CONFIGURACIÓN DE DERIVED DATA ---
        // Almacenar DerivedData localmente en el workspace evita conflictos entre compilaciones
        DERIVED_DATA = "${WORKSPACE}/DerivedData"
    }

    stages {
        stage('Limpieza preliminar') {
            steps {
                echo 'Limpiando el directorio de Derived Data anterior...'
                sh "rm -rf ${DERIVED_DATA}"
            }
        }

        stage('Ejecutar Pruebas (Tests)') {
            steps {
                echo 'Ejecutando pruebas unitarias y de UI...'
                // Se utiliza la acción 'test' de xcodebuild
                sh """
                    xcodebuild test \
                    -project "${PROJECT_NAME}" \
                    -scheme "${SCHEME_NAME}" \
                    -destination "${TEST_DEVICE}" \
                    -derivedDataPath "${DERIVED_DATA}"
                """
            }
        }

        stage('Compilar para Simulador') {
            steps {
                echo 'Compilando la aplicación para verificar errores de integración...'
                // Se utiliza 'build' con SDK de simulador (no requiere firma de código)
                sh """
                    xcodebuild build \
                    -project "${PROJECT_NAME}" \
                    -scheme "${SCHEME_NAME}" \
                    -sdk iphonesimulator \
                    -destination "${TEST_DEVICE}" \
                    -derivedDataPath "${DERIVED_DATA}"
                """
            }
        }
    }

    post {
        always {
            echo 'Limpiando espacio de DerivedData tras finalizar la ejecución...'
            sh "rm -rf ${DERIVED_DATA}"
        }
        success {
            echo '¡La compilación y las pruebas finalizaron con éxito!'
        }
        failure {
            echo 'Hubo un fallo en la compilación o en las pruebas. Revisa los logs de xcodebuild.'
        }
    }
}
