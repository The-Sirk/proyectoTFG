package tfg.avellaneda.ira.model;

import java.util.List;

/**
 *
 * @author Adrián
 */
public class TmdbResponse {

    private List<MovieEntrada> results;

    public List<MovieEntrada> getResults() {
        return results;
    }

    public void setResults(List<MovieEntrada> results) {
        this.results = results;
    }
}
