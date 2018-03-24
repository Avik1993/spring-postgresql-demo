package pcfdemo.model;

import lombok.AccessLevel;
import lombok.Data;
import lombok.Setter;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import java.io.Serializable;

@Data
@Entity
@Table(name = "vote_totals")
public class VoteTotalsView implements Serializable {

    @Id
    @Setter(AccessLevel.NONE)
    private long id;

    @NotNull
    @Setter(AccessLevel.NONE)
    private String election;

    @NotNull
    @Setter(AccessLevel.NONE)
    private String candidate;

    @NotNull
    @Setter(AccessLevel.NONE)
    private Integer votes;
}
