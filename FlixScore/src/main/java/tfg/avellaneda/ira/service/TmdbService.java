package tfg.avellaneda.ira.service;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class TmdbService {

    // Declarar el Logger
    private static final Logger logger = LoggerFactory.getLogger(TmdbService.class);

    private final WebClient webClient;
    private final String apiKey; // Puede ser null o vacío si no se encuentra
    private static final String BASE_URL = "https://api.themoviedb.org/3";

    // Spring inyectará WebClient.Builder automáticamente
    public TmdbService(WebClient.Builder webClientBuilder) {

        // Cargar el .env
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();

        String key = dotenv.get("TMDB_API_KEY");

        // Si la clave no se encuentra, asigna null y muestra una advertencia.
        if (key == null || key.trim().isEmpty()) {
            logger.warn(
                    "ADVERTENCIA: La variable de entorno TMDB_API_KEY no está definida. La funcionalidad de búsqueda de TMDB estará deshabilitada.");
            this.apiKey = null; // o this.apiKey = "";
        } else {
            this.apiKey = key;
        }

        // El WebClient puede inicializarse de todas formas
        this.webClient = webClientBuilder.baseUrl(BASE_URL).build();
    }

    /**
     * Proporciona un RequestHeadersUriSpec para iniciar una petición GET
     */
    public WebClient.RequestHeadersUriSpec<?> getBaseRequest() {
        return webClient.get();
    }

    /**
     * Proporciona la API Key
     */
    public String getApiKey() {
        return apiKey;
    }
}