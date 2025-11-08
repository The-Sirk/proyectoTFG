package tfg.avellaneda.ira.model;

import java.util.ArrayList;
import java.util.List;
import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * Modelo de Usuario para la obtención de su contenido en Firebase
 * 
 * @author Israel
 *         Creación del modelo
 * @author Adrián
 *         Corrección del modelo para la obtención de datos de los arrays
 *         Se añade validación al correo electrónico
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModeloUsuario {

    @DocumentId
    private String documentID;

    @NotBlank(message = "El correo no puede estar vacío")
    @Email(message = "El formato del correo electrónico no es válido")
    private String correo;

    private String imagen_perfil;

    @NotBlank(message = "El nick es obligatorio")
    private String nick;

    private List<String> amigos_id = new ArrayList<>();

    private List<Long> peliculas_criticadas = new ArrayList<>();

    private List<Long> peliculas_favoritas = new ArrayList<>();

    private List<Long> peliculas_vistas = new ArrayList<>();

    /**
     * Constructor de copia que permite crear una nueva instancia mutable a partir
     * de una existente.
     * Es necesario porque Lombok no lo genera.
     */
    public ModeloUsuario(ModeloUsuario other) {
        this.documentID = other.documentID;
        this.correo = other.correo;
        this.imagen_perfil = other.imagen_perfil;
        this.nick = other.nick;

        // Se copian las listas para evitar modificar accidentalmente la lista original
        this.amigos_id = other.amigos_id != null ? new ArrayList<>(other.amigos_id) : new ArrayList<>();
        this.peliculas_criticadas = other.peliculas_criticadas != null ? new ArrayList<>(other.peliculas_criticadas)
                : new ArrayList<>();
        this.peliculas_favoritas = other.peliculas_favoritas != null ? new ArrayList<>(other.peliculas_favoritas)
                : new ArrayList<>();
        this.peliculas_vistas = other.peliculas_vistas != null ? new ArrayList<>(other.peliculas_vistas)
                : new ArrayList<>();
    }
}