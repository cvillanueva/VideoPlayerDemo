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
        TEST_DEVICE  = 'platform=iOS Simulator,name=iPhone 17,OS=26.3.1'
        
        // --- CONFIGURACIÓN DE DERIVED DATA ---
        // Almacenar DerivedData localmente en el workspace evita conflictos entre compilaciones
        DERIVED_DATA = "${WORKSPACE}/DerivedData"

        ARCHIVE_PATH = "./build/${SCHEME_NAME}.xcarchive"
        IPA_PATH     = "./build/OutputIPA"
    }

    stages {
        stage('Limpieza preliminar') {
            steps {
                echo 'Limpiando el directorio de Derived Data anterior...'
                sh "rm -rf ${DERIVED_DATA}"
            
                echo 'Limpiando directorio build...'
                sh "rm -rf ./build"
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

        stage('Generar IPA') {
            steps {
                echo 'Generando .xcarchive...'
                sh """
                    xcodebuild archive \
                    -project "${PROJECT_NAME}" \
                    -scheme "${SCHEME_NAME}" \
                    -configuration Release \
                    -archivePath "${ARCHIVE_PATH}" \
                    -destination 'generic/platform=iOS'
                """

                echo 'Exporting IPA...'
                sh """
                    xcodebuild -exportArchive \
                    -archivePath "${ARCHIVE_PATH}" \
                    -exportPath "${IPA_PATH}" \
                    -exportOptionsPlist ExportOptions.plist
                """
            }
        }
    }

    post {
        always {
            echo 'Limpiando espacio de DerivedData tras finalizar la ejecución...'
            sh "rm -rf ${DERIVED_DATA}"
            
            echo 'Limpiando directorio build...'
            sh "rm -rf ./build"
        }
        success {
            echo '¡La compilación y las pruebas finalizaron con éxito!'
        }
        failure {
            echo 'Hubo un fallo en la compilación o en las pruebas. Revisa los logs de xcodebuild.'
        }
    }
}
