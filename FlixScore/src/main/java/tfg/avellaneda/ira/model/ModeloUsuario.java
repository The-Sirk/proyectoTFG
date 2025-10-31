package tfg.avellaneda.ira.model;

import java.util.ArrayList;
import java.util.List;
import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Modelo de Usuario para la obtención de su contenido en Firebase
 * 
 * @author Israel
 *         Creación del modelo
 * @author Adrián
 *         Corrección del modelo para la obtención de datos de los arrays
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModeloUsuario {

    @DocumentId
    private String documentID;

    private String correo;

    private String imagen_perfil;

    private String nick;

    private List<String> amigos_id = new ArrayList<>();

    private List<Long> peliculas_criticadas = new ArrayList<>();

    private List<Long> peliculas_favoritas = new ArrayList<>();

    private List<Long> peliculas_vistas = new ArrayList<>();
}