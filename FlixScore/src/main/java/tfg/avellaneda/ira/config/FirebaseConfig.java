package tfg.avellaneda.ira.config;

import javax.annotation.PostConstruct;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;

/**
 * Clase de configuracion para inicializar Firebase
 * TODO: Crear variables .env para no hardcodear
 * 
 * @author Israel
 */
@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() {
        if (FirebaseApp.getApps().isEmpty()) {
            try {
                // Utiliza el método estándar de credenciales por defecto de Google Cloud
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.getApplicationDefault())
                        .setProjectId("tfg-flixscore")
                        .build();
                return FirebaseApp.initializeApp(options);
            } catch (Exception e) {
                // ESTO ES CLAVE: Lanza la excepción para que Cloud Run vea el error en los
                // logs.
                throw new RuntimeException("Error al inicializar Firebase App.", e);
            }
        }
        return FirebaseApp.getInstance();
    }

    @Bean
    public FirebaseAuth firebaseAuth(FirebaseApp firebaseApp) {
        return FirebaseAuth.getInstance(firebaseApp);
    }
}