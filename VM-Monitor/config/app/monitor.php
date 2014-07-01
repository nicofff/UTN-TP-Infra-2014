<html>
<head>
<meta http-equiv="refresh" content="2">

<style>
table, td, th {
    border: 1px solid green;
}
table {
    margin: auto auto;
}
</style>
</head>
<body>

<?php



function connect() {
    $DB_USER = "root";
    $DB_PASS = "InfraYVirt";
    $DB_NAME = "monitor";
    $DB_SERVER= "localhost";

    $MYSQLI = new mysqli($DB_PRIMARY_SERVER,$DB_USER,$DB_PASS,$DB_NAME);
    $MYSQLI->set_charset("utf8");
    if (mysqli_error($MYSQLI)) {
        print_r(mysqli_error($MYSQLI));
        die();
    }
    return $MYSQLI;
}

function select() {

        $query = "SELECT log.date, hosts.name as hostName, hosts.address as hostAddress, services.name, services.command, log.output, log.exit_code ";
        $query = $query."from hosts, checks, services, log ";
        $query = $query."where hosts.id = checks.host and services.id = checks.service and log.checkid = checks.id ";
        $query = $query."order by log.date DESC LIMIT 10";

        $MYSQLI = connect();

        if ($result = $MYSQLI->query($query)) {
            echo "<table style='border: 1px solid black;'>";
            echo "<tr>";
            echo '<td>Date</td>'.'<td>Host Name</td>'.'<td>Host Address'.'<td>Name</td>'. '<td>Command</td>'.'<td>Output</td>'.'<td>Exit_code</td>';
            echo "</tr>";   
            while($row = mysqli_fetch_array($result)) {
              echo "<tr>";
              echo getField($row, 'date').getField($row, 'hostName').getField($row, 'hostAddress').getField($row, 'name').getField($row, 'command');
              echo getField($row, 'output').getField($row, 'exit_code');
              echo "</tr>";
            }
            echo "</table>";
            $MYSQLI->close();
        } else {
            die();
        }
}

function getField($row, $field) {

    return "<td style='padding: 15px;'>".$row[$field] . "</td>";
}

select();

?>

</body>
</html>

<!--
    public function estaRegistrado() {
        include "dbConn.php"; # me da el obj $MYSQLI
        $query = "SELECT * from Inscriptos where (TipoDoc = " . $this->tipoDoc . " AND NumeroDoc = " . $this->numeroDoc . ") OR Email = '" . $this->email . "'";
        if ($result = $MYSQLI->query($query)) {
            $resObj = $result->fetch_object();
            $MYSQLI->close();
            if ($result->num_rows == 0) {
                return false;
            } else {
                $this->email = $resObj->Email;
                return true;
            }
        } else {
            die();
        }
    }
    public function save() {
        include "dbConn.php"; # me da el obj $MYSQLI
        $query = "INSERT INTO Inscriptos (Apellido,Nombre,TipoDoc,NumeroDoc,PaisNac,Profesion,Especialidad,PaisRes,Provincia,Email,Categoria,Laboratorio,CodigoInscripcion) ";
        $query.= "VALUES ('" . $this->apellido . "','" . $this->nombre . "'," . $this->tipoDoc . "," . $this->numeroDoc . "," . $this->paisNac . "," . $this->profesion . ",'" . $this->especialidad;
        $query .= "'," . $this->paisRes . ",'" . $this->provincia . "','" . $this->email . "'," . $this->categoria . "," . $this->laboratorio . ",'" . $this->codigoInscripcion . "')";
        $MYSQLI->query($query);
        if (mysqli_error($MYSQLI)) {
            print_r(mysqli_error($MYSQLI));
            die();
            return false;
        } else {
            $MYSQLI->close();
        }
    }

-->