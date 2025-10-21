package tfg.avellaneda.ira.model;

import com.google.cloud.firestore.annotation.DocumentId;

/**
 * Modelo de crítica, se utiliza para que un usuario opine sobre una pelicula
 * y que en las búsquedas se puedan obtener los datos.
 * @author Adrián
 */
public class ModeloCritica {
    
    private String usuarioUID;
    private int peliculaID;
    private int puntuacion;
    private String comentario;
    @DocumentId
    private String documentID;
    
    // Constructores de la clase
    public ModeloCritica(){};
    
    // Constructor para la creación (no incluye documentID)
    public ModeloCritica(String usuarioUID, int peliculaID, int puntuacion, String comentario) {
        this.usuarioUID = usuarioUID;
        this.peliculaID = peliculaID;
        this.puntuacion = puntuacion;
        this.comentario = comentario;
        // El documentID se genera/asigna en el servicio (usuarioUID + "_" + peliculaID)
    }
    
    // Constructor para la recuperación (incluye documentID, aunque la anotación lo hace por ti)
    public ModeloCritica(String usuarioUID, int peliculaID, int puntuacion, String comentario, String documentID) {
        this.usuarioUID = usuarioUID;
        this.peliculaID = peliculaID;
        this.puntuacion = puntuacion;
        this.comentario = comentario;
        this.documentID = documentID;
    }

    
    //------------ GETTERS / SETTERS ------------
    public String getUsuarioUID() {
        return usuarioUID;
    }
    public void setUsuarioUID(String usuarioUID) {
        this.usuarioUID = usuarioUID;
    }

    
    public int getPeliculaID() {
        return peliculaID;
    }

    public void setPeliculaID(int peliculaID) {
        this.peliculaID = peliculaID;
    }

    
    public int getPuntuacion() {
        return puntuacion;
    }

    public void setPuntuacion(int puntuacion) {
        this.puntuacion = puntuacion;
    }

    
    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }
    
    @DocumentId
    public String getDocumentID() {
        return documentID;
    }

    public void setDocumentID(String documentID) {
        this.documentID = documentID;
    }
}
