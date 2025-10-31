package tfg.avellaneda.ira.model;

import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * He añadido Lombok para facilitar la creación de clases modelo.
 * Lombok genera automaticamente constructores, getters, setters, toString, etc.
 * @author Israel
 */

/**
 * Modelo de crítica, se utiliza para que un usuario opine sobre una pelicula
 * y que en las búsquedas se puedan obtener los datos.
 * 
 * @author Adrián
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModeloCritica {

    private String usuarioUID;
    private int peliculaID;
    private int puntuacion;
    private String comentario;
    @DocumentId
    private String DocumentID;

}
