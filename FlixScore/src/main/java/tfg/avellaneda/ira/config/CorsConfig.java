package tfg.avellaneda.ira.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // Aplica esta configuración a TODAS las rutas de tu API
        registry.addMapping("/**")
                // Permite peticiones desde CUALQUIER origen
                // En producción, mejor especificar solo los dominios seguros
                .allowedOrigins("*")
                // Métodos HTTP permitidos
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                // Permite cualquier cabecera
                .allowedHeaders("*");
    }
}