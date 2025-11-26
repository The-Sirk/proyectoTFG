package tfg.avellaneda.ira.controller;

import tfg.avellaneda.ira.service.FirebaseAdminService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;

@RestController
@RequestMapping("/admin/users")
@Tag(name = "Administración de Usuarios Firebase", description = "Endpoints para la gestión de usuarios Auth de Firebase")
public class FirebaseAuthController {

    private final FirebaseAdminService firebaseAdminService;

    public FirebaseAuthController(FirebaseAdminService firebaseAdminService) {
        this.firebaseAdminService = firebaseAdminService;
    }

    // --------------------------------------------------------------------------
    // ASIGNACIÓN DE ROL
    // --------------------------------------------------------------------------
    @Operation(summary = "Asigna un Rol (Custom Claim) a un usuario", description = "Establece un Custom Claim de rol ('user', 'admin', 'sadmin') a un usuario por su UID. Esto revoca sus tokens.", responses = {
            @ApiResponse(responseCode = "200", description = "Rol asignado exitosamente y tokens revocados.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "400", description = "Petición inválida: UID no encontrado, rol no válido o formato incorrecto.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "No autorizado: sin autenticación o token inválido."),
            @ApiResponse(responseCode = "403", description = "Prohibido: se requiere rol ADMIN."),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o del Firebase Admin SDK.")
    })
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{uid}/role")
    public ResponseEntity<Map<String, Object>> asignarRol(
            @Parameter(description = "El User ID de Firebase del usuario a modificar.") @PathVariable String uid,
            @Parameter(description = "El rol a asignar ('user', 'admin', 'sadmin').") @RequestParam String role) {

        Map<String, Object> result = firebaseAdminService.asignarRolUsuario(uid, role);

        if ("error".equals(result.get("status"))) {
            return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
        }
        return ResponseEntity.ok(result);
    }

    // --------------------------------------------------------------------------
    // LISTADO PAGINADO
    // --------------------------------------------------------------------------
    @Operation(summary = "Lista paginada de usuarios de Auth", description = "Devuelve una lista de usuarios de Firebase Auth, con un token para la siguiente página.", responses = {
            @ApiResponse(responseCode = "200", description = "Listado de usuarios obtenido exitosamente.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "No autorizado: sin autenticación o token inválido."),
            @ApiResponse(responseCode = "403", description = "Prohibido: se requiere rol ADMIN."),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o del Firebase Admin SDK.")
    })
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<Map<String, Object>> listarUsuarios(
            @Parameter(description = "Número máximo de usuarios a devolver (Max 1000). Por defecto 50.") @RequestParam(defaultValue = "50") int maxResults,
            @Parameter(description = "Token opcional para obtener la siguiente página de resultados.") @RequestParam(required = false) String nextPageToken) {

        Map<String, Object> result = firebaseAdminService.listarUsuariosAuth(maxResults, nextPageToken);

        if ("error".equals(result.get("status"))) {
            return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return ResponseEntity.ok(result);
    }

    // --------------------------------------------------------------------------
    // BANEAR / DESBANEAR
    // --------------------------------------------------------------------------
    @Operation(summary = "Habilita o Deshabilita (Banea) un usuario", description = "Establece el estado 'disabled' de un usuario por su UID. Deshabilitar revoca sus tokens.", responses = {
            @ApiResponse(responseCode = "200", description = "Estado de usuario cambiado exitosamente.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "400", description = "Petición inválida: Usuario no encontrado.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "No autorizado: sin autenticación o token inválido."),
            @ApiResponse(responseCode = "403", description = "Prohibido: se requiere rol ADMIN."),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o del Firebase Admin SDK.")
    })
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{uid}/disable")
    public ResponseEntity<Map<String, Object>> toggleDisable(
            @Parameter(description = "El User ID de Firebase del usuario a modificar.") @PathVariable String uid,
            @Parameter(description = "Estado deseado: 'true' para deshabilitar (banear), 'false' para habilitar (desbanear).") @RequestParam boolean disabled) {

        Map<String, Object> result = firebaseAdminService.deshabilitarUsuario(uid, disabled);

        if ("error".equals(result.get("status"))) {
            return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
        }
        return ResponseEntity.ok(result);
    }

    // --------------------------------------------------------------------------
    // RESET DE CONTRASEÑA
    // --------------------------------------------------------------------------
    @Operation(summary = "Fuerza la revocación de tokens y el restablecimiento de contraseña", description = "Revoca todos los tokens de sesión de un usuario y le envía un enlace por email para restablecer su contraseña.", responses = {
            @ApiResponse(responseCode = "200", description = "Proceso de restablecimiento iniciado y email enviado.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "400", description = "Petición inválida: Usuario no encontrado o usuario sin email asociado.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "No autorizado: sin autenticación o token inválido."),
            @ApiResponse(responseCode = "403", description = "Prohibido: se requiere rol ADMIN."),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o del Firebase Admin SDK.")
    })
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/{uid}/reset-password")
    public ResponseEntity<Map<String, Object>> forzarResetPassword(
            @Parameter(description = "El User ID de Firebase del usuario.") @PathVariable String uid) {

        Map<String, Object> result = firebaseAdminService.forzarRestablecimientoContrasena(uid);

        if ("error".equals(result.get("status"))) {
            return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
        }
        return ResponseEntity.ok(result);
    }

    // --------------------------------------------------------------------------
    // ELIMINAR USUARIO
    // --------------------------------------------------------------------------
    @Operation(summary = "Elimina permanentemente un usuario", description = "Elimina la cuenta de un usuario de Firebase Authentication por su UID.", responses = {
            @ApiResponse(responseCode = "200", description = "Usuario eliminado exitosamente.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "400", description = "Petición inválida: Usuario no encontrado.", content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "No autorizado: sin autenticación o token inválido."),
            @ApiResponse(responseCode = "403", description = "Prohibido: se requiere rol ADMIN."),
            @ApiResponse(responseCode = "500", description = "Error interno del servidor o del Firebase Admin SDK.")
    })
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{uid}")
    public ResponseEntity<Map<String, Object>> eliminarUsuario(
            @Parameter(description = "El User ID de Firebase del usuario a eliminar.") @PathVariable String uid) {

        Map<String, Object> result = firebaseAdminService.eliminarUsuario(uid);

        if ("error".equals(result.get("status"))) {
            return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
        }
        return ResponseEntity.ok(result);
    }
}