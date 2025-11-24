package tfg.avellaneda.ira.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.ListUsersPage;
import com.google.firebase.auth.UserRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class FirebaseAdminService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseAdminService.class);
    private static final String DEFAULT_ROLE = "user";
    private static final Set<String> VALID_ROLES = Set.of("user", "admin");

    @Value("${FIREBASE_API_KEY:${firebase.api-key:}}")
    private String firebaseApiKey;

    // -----------------------------------------------------------------------
    // Función para establecer el Custom Claim 'role' y revocar tokens
    // -----------------------------------------------------------------------
    public Map<String, Object> asignarRolUsuario(String userUid, String role) {
        String roleLower = role.toLowerCase();

        if (!VALID_ROLES.contains(roleLower)) {
            logger.error("Intento de asignar rol no válido: {} al UID {}", role, userUid);
            return Map.of("status", "error",
                    "detail", String.format("Rol no válido: %s. Roles permitidos: %s.", role, VALID_ROLES));
        }

        try {
            FirebaseAuth auth = FirebaseAuth.getInstance();
            Map<String, Object> customClaims = new HashMap<>();
            customClaims.put("role", roleLower);

            // Establecer Custom Claim: Actualiza el claim 'role' del usuario.
            auth.setCustomUserClaims(userUid, customClaims);

            // Revocar tokens: Fuerza el cierre de sesión del usuario en todos los
            // dispositivos.
            auth.revokeRefreshTokens(userUid);

            logger.info("Rol '{}' asignado y tokens revocados para UID: {}", roleLower, userUid);

            return Map.of("status", "success",
                    "uid", userUid,
                    "role", roleLower,
                    "message", String.format("Rol '%s' asignado correctamente.", roleLower));

        } catch (FirebaseAuthException e) {
            logger.error("Error de autenticación de Firebase al asignar rol a UID {}: {}", userUid, e.getMessage());
            return Map.of("status", "error", "detail", "Fallo en la autenticación de Firebase: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error inesperado al asignar rol a UID {}: {}", userUid, e.getMessage(), e);
            return Map.of("status", "error", "detail", "Error inesperado: " + e.getMessage());
        }
    }

    // -------------------------------------------------------------------
    // Mapea un objeto UserRecord de Firebase a la estructura de respuesta
    // -------------------------------------------------------------------
    private Map<String, Object> mapUsuarioParaRespuesta(UserRecord user) {
        String userRole = DEFAULT_ROLE;
        if (user.getCustomClaims() != null && user.getCustomClaims().containsKey("role")) {
            userRole = (String) user.getCustomClaims().get("role");
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                .withZone(ZoneId.systemDefault());

        long creationTimeMillis = user.getUserMetadata().getCreationTimestamp();
        long lastSignInTimeMillis = user.getUserMetadata().getLastSignInTimestamp();

        return Map.of(
                "uid", user.getUid(),
                "email", user.getEmail() != null ? user.getEmail() : "",
                "displayName", user.getDisplayName() != null ? user.getDisplayName() : "",
                "disabled", user.isDisabled(),
                "role", userRole,
                "emailVerified", user.isEmailVerified(),
                "creationTime",
                creationTimeMillis != 0
                        ? formatter.format(new Date(creationTimeMillis).toInstant())
                        : null,
                "lastSignInTime",
                lastSignInTimeMillis != 0
                        ? formatter.format(new Date(lastSignInTimeMillis).toInstant())
                        : null);
    }

    // --------------------------------------------------------------
    //               Función de listado de usuarios      
    // --------------------------------------------------------------
    public Map<String, Object> listarUsuariosAuth(int maxResultados, String siguienteTokenPagina) {
        List<Map<String, Object>> usuariosMapeados = new ArrayList<>();

        try {
            ListUsersPage page = FirebaseAuth.getInstance()
                    .listUsers(siguienteTokenPagina, maxResultados);

            for (UserRecord user : page.getValues()) {
                usuariosMapeados.add(mapUsuarioParaRespuesta(user));
            }

            usuariosMapeados.sort(Comparator.comparing(
                    m -> (String) m.get("email"),
                    String.CASE_INSENSITIVE_ORDER));

            return Map.of(
                    "status", "success",
                    "usuarios", usuariosMapeados,
                    "siguienteTokenPagina", page.getNextPageToken() != null ? page.getNextPageToken() : "");

        } catch (FirebaseAuthException e) {
            logger.error("Error de Firebase al listar usuarios: {}", e.getMessage());
            return Map.of("status", "error", "detail", "Error de Firebase: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error inesperado al listar usuarios: {}", e.getMessage(), e);
            return Map.of("status", "error", "detail", "Error inesperado: " + e.getMessage());
        }
    }

    // ---------------------------------------------------------------------
    //         Funcion de control de estado (Habilitar/Deshabilitar)        
    // ---------------------------------------------------------------------
    public Map<String, Object> deshabilitarUsuario(String userUid, boolean deshabilitar) {
        String accion = deshabilitar ? "deshabilitado" : "habilitado";

        try {
            UserRecord.UpdateRequest request = new UserRecord.UpdateRequest(userUid)
                    .setDisabled(deshabilitar);

            UserRecord user = FirebaseAuth.getInstance().updateUser(request);

            if (deshabilitar) {
                FirebaseAuth.getInstance().revokeRefreshTokens(userUid);
                logger.info("Tokens revocados para el usuario UID: {}", userUid);
            }

            logger.info("Usuario UID: {} {} correctamente.", userUid, accion);

            return Map.of("status", "success",
                    "uid", user.getUid(),
                    "disabled", user.isDisabled(),
                    "message", String.format("Usuario %s %s correctamente.", user.getUid(), accion));

        } catch (FirebaseAuthException e) {
            if (e.getErrorCode().equals("user-not-found")) {
                logger.error("Intento de cambiar estado a UID no encontrado: {}", userUid);
                return Map.of("status", "error", "detail",
                        String.format("Usuario con UID '%s' no encontrado.", userUid));
            }
            logger.error("Error de autenticación de Firebase al cambiar estado del UID {}: {}", userUid,
                    e.getMessage());
            return Map.of("status", "error", "detail", "Fallo en la autenticación de Firebase: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error inesperado al cambiar estado del UID {}: {}", userUid, e.getMessage(), e);
            return Map.of("status", "error", "detail", "Error inesperado: " + e.getMessage());
        }
    }

    // ----------------------------------------------------
    //         Función de eliminación de usuarios          
    // ----------------------------------------------------
    public Map<String, Object> eliminarUsuario(String userUid) {
        try {
            FirebaseAuth.getInstance().deleteUser(userUid);

            logger.warn("Usuario con UID {} ELIMINADO permanentemente.", userUid);

            return Map.of("status", "success", "uid", userUid);

        } catch (FirebaseAuthException e) {
            if (e.getErrorCode().equals("user-not-found")) {
                String detail = String.format("Usuario con UID '%s' no encontrado.", userUid);
                logger.warn(detail);
                return Map.of("status", "error", "detail", detail);
            }
            String detail = String.format("Error de Firebase al eliminar a %s: %s", userUid, e.getMessage());
            logger.error(detail);
            return Map.of("status", "error", "detail", detail);
        } catch (Exception e) {
            String detail = String.format("Error desconocido al intentar eliminar usuario: %s", e.getMessage());
            logger.error(detail, e);
            return Map.of("status", "error", "detail", detail);
        }
    }

    // -------------------------------------------------------------------
    //         Función de reestablecimiento de contraseña forzoso      
    // -------------------------------------------------------------------
    public Map<String, Object> forzarRestablecimientoContrasena(String userUid) {
        try {
            FirebaseAuth auth = FirebaseAuth.getInstance();
            UserRecord user = auth.getUser(userUid);

            // Por el diseño de nuestro loggin no se debería dispara este if, pero por si
            // acaso.
            if (user.getEmail() == null || user.getEmail().isEmpty()) {
                logger.error("Intento de restablecer contraseña a usuario sin correo: {}", userUid);
                return Map.of("status", "error", "detail",
                        String.format("El usuario con UID %s no tiene un correo asociado.", userUid));
            }

            auth.revokeRefreshTokens(userUid);
            logger.warn("Tokens de sesión revocados para UID: {}. Usuario forzado a cerrar sesión.", userUid);

            // Se envía el correo de restablecimiento
            String url = String.format("https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s",
                    firebaseApiKey);
            Map<String, String> payload = Map.of(
                    "requestType", "PASSWORD_RESET",
                    "email", user.getEmail());

            // Se utiliza RestTemplate para realizar la llamada HTTP POST.
            RestTemplate restTemplate = new RestTemplate();
            restTemplate.postForLocation(url, payload);

            logger.info("Correo de restablecimiento enviado a {}. UID: {}", user.getEmail(), userUid);
            return Map.of(
                    "status", "success",
                    "uid", userUid,
                    "email", user.getEmail(),
                    "message",
                    String.format("Correo de restablecimiento de contraseña enviado a %s.", user.getEmail()));

        } catch (FirebaseAuthException e) {
            if (e.getErrorCode().equals("user-not-found")) {
                logger.error("Intento de restablecer contraseña a UID no encontrado: {}", userUid);
                return Map.of("status", "error", "detail",
                        String.format("Usuario con UID '%s' no encontrado.", userUid));
            }
            logger.error("Error de Firebase al generar enlace para UID {}: {}", userUid, e.getMessage());
            return Map.of("status", "error", "detail", "Fallo en la autenticación de Firebase: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Error inesperado al intentar restablecer contraseña para UID {}: {}", userUid, e.getMessage(),
                    e);
            return Map.of("status", "error", "detail", "Error inesperado: " + e.getMessage());
        }
    }
}