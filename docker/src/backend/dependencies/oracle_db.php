<?php

    include_once ("oracle_connect.php");

    //PHP class for querying the Oracle DB:
    class oracle_db
    {
        private $conn;
        private $exit_on_failure = true;

        //this property stores the numeric value used to generate unique placeholders
        private $placeholder_counter = 0;

        //class constructor:
        function __construct($DB_USER = '', $DB_PASS = '', $DB_HOST = '', $exit_on_failure = true)
        {
            global $output_message;

            if (empty($DB_USER))
            {
                $DB_USER = DB_USER;
                $DB_PASS = DB_PASS;
                $DB_HOST = DB_HOST;
            }

            $this->exit_on_failure = $exit_on_failure;

            //connect to the database
            if (!($this->conn = oracle_connect($DB_USER, $DB_PASS, $DB_HOST)))
            {
                //the SQL statement could not be executed:
                if (isset($output_message))
                {
//                    $output_message->add_message("Cannot connect to the database");

                    $e = oci_error();

                    $output_message->add_message("oci_connect() error: ".var_export($e, true));
                }
                else
                {

//                    echo "Cannot connect to the database\r\n";

                    $e = oci_error();

//                    echo "oci_connect() error: ".var_export($e, true)."\r\n";

                }

                if ($this->exit_on_failure)
                {
/*                    if (isset($output_message))
                        $output_message->add_message("halting script execution immdiately");
                    else
                        echo "halting script execution immediately\r\n";
*/
                    exit;
                }
            }
        }

        //accessor method:
        function is_connected(&$error_info)
        {
            //set the $error_info with the oci_error() information
            $error_info = oci_error();

            return $this->conn;
        }

        function close_connection()
        {
//            echo "running the close_connection($this->conn) method for the oracle_db class\r\n";

            //close the connection:
            return oci_close($this->conn);
        }


        //class destructor:
        function __destruct()
        {
			//close the DB connection:
			$this->close_connection();

			//release all object properties from memory
            unset($this->conn);
            unset($this->exit_on_failure);
            unset($this->placeholder_counter);
        }

        function return_conn()
        {
            return $this->conn;
        }

        function rollback()
        {
            global $output_message;

            //found this error on multiple executions:
            //ORA-03135: connection lost contact

            if (!($return_value = oci_rollback($this->conn)))
            {

                //the SQL statement could not be executed:
                if (isset($output_message))
                {
                    $output_message->add_message("The current database transaction could not be rolled back successfully");

                    $e = oci_error($this->conn);

                    $output_message->add_message("oci_rollback() error: ".var_export($e, true));
                }
                else
                    echo "The current database transaction could not be rolled back successfully";


                if ($this->exit_on_failure)
                {
                    if (isset($output_message))
                    {
                        $output_message->add_message("halting script execution immdiately (rollback method)");
                    }
                    exit;
                }


            }

            return $return_value;
        }

        function commit()
        {
            global $output_message;

//            echo "Commit the current database transaction\r\n";


            if (!($return_value = oci_commit($this->conn)))
            {

                //the SQL statement could not be executed:
                if (isset($output_message))
                {
                    $output_message->add_message("The current database transaction could not be committed successfully");

                    $e = oci_error($this->conn);

                    $output_message->add_message("oci_rollback() error: ".var_export($e, true));
                }
//                else
//                    echo "The current database transaction could not be committed successfully";


                if ($this->exit_on_failure)
                {
                    if (isset($output_message))
                    {
                        $output_message->add_message("halting script execution immdiately (commit method)");
                    }
                    exit;
                }


            }

            return ;
        }


        //method to construct an insert query SQL text with a dynamic list of field names and bind variables:
        function construct_simple_insert_query($table_name, $field_list, $bind_list)
        {
/*            echo "running construct_simple_insert_query($table_name)<BR>";

            echo "field list:<BR>";
            var_dump($field_list);
            echo "<BR>bind list:<BR>";
            var_dump($bind_list);
*/

            return "INSERT INTO ".$table_name." (".implode(", ", $field_list).") VALUES (".implode(", ", $bind_list).")";
        }


        //execute the sql query.  In order to properly use the $return_id feature the corresponding placeholder must be ":RETURN_ID" and a data type of INT
				//$bind_array is either an empty array or it is a nested array of elements that define the bind variable name, value, size, and if it is an OUT variable (for PL/SQL procedure calls - true if the variable is an OUT variable and false if it is not) of each parameter: $bind_array[0] = array(":var_id", $var_value, $var_size, $out_var)
        function query($sql, &$stid, &$return_id, $bind_array = array(), $query_mode = OCI_COMMIT_ON_SUCCESS, $returning_args = array())
        {
            global $output_message;

//            echo "running query ($sql, ".var_export($bind_array, true).", $query_mode, ".var_export($returning_args, true).")";

			$return_value = true;

            $return_id = null;

            //check if the connection is null:
            if ($return_value = (!is_null($this->conn)))
            {
//                echo "connection variable is valid\r\n";

                //the connection is still active, execute the query:
                if ($return_value = ($stid = oci_parse($this->conn, $sql)))
                {
//                    echo "statement was parsed successfully\r\n";

                    //bind the query variables and return the $return_vars for any LOB variables:
                    if ($return_value = $this->bind_values($stid, $bind_array, $return_id_exists, $return_vars, $returning_args))
                    {
//                        echo "variables bound successfully\r\n";


                        //execute the query
                        if ($return_value = ($rc = oci_execute($stid, $query_mode)))
                        {
//                            echo "query executed successfully\r\n";


                            //the return id exists
                            if ($return_id_exists)
                            {
                                //find the
                                $found = false;

                                for ($i = 0; ((!$found) && ($i < count($bind_array))); $i++)
                                {
                                    //check if the current variable is the return id
                                    if ($found = ($bind_array[$i][0] == ":RETURN_ID") || ((isset($bind_array[$i][3])) && ($bind_array[$i][3])))
                                    {
                                        //set the value of $return_id to the value of the :RETURN_ID/OUT variable:
                                        $return_id = $bind_array[$i][1];

                //                        echo "The value of \$return_id is: " . $return_id."<BR>";
                                    }
                                }
                            }


//                            echo "The value of \$return_vars is: " . var_export($return_vars, true)."\r\n";




                            if (!empty($return_vars))
                            {

//                                echo "There are returning_args, process them\r\n";

                                //check if there are any LOB values that need to be saved in the database
//                                for ($i = 0; (($rc) && ($i < count($return_vars))); $i++)

                                foreach ($return_vars as $key => $value)
                                {

//                                    echo "checking \$return_vars[$key]\r\n";


                                    if (($returning_args['data_type'][$key] == 'CLOB') || ($returning_args['data_type'][$key] == 'BLOB'))
                                    {
                                        //set the LOB value:
//                                        echo "set the LOB value\r\n";

                                        //set the LOB value:
                                        if (!($rc = $return_vars[$key]->save($returning_args['values'][$key])))
                                        {
//                                            echo "The LOB value was not set correctly\r\n";

                                            break;
                                        }
                                        else
                                        {
                                            //LOB value was set correctly:
//                                            echo "The LOB value was set correctly\r\n";

                                        }

//                                        echo "free resources from LOB variable\r\n";

                                        //free the resources from the LOB variable:
                                        $return_vars[$key]->free();
                                    }

                                }
                            }

                            //check if the query and bind vars were successful and if this query should be committed:
                            if ((!empty($returning_args)) && ($rc) && ($query_mode == OCI_COMMIT_ON_SUCCESS))
                            {
//                                echo "check if the query and bind vars were successful and if this query should be committed\r\n";

                                //commit the transaction:
                                if (!($rc = $this->commit()))
                                {
									//the commit failed
									$return_value = false;
									
                                    $e = oci_error($stid);

//                                    echo "oci_execute() error: ".var_export($e, true)."\r\n";


                                    //the SQL statement could not be executed:
                                    if (isset($output_message))
                                    {
//                                        echo $output_message->add_message("The database statement could not be executed successfully");


//                                        echo $output_message->add_message("oci_execute() error: ".var_export($e, true));
                                    }
                                    else
                                    {
//                                        echo "The database statement could not be executed successfully";
                                    }
                                }
                            }


//                            echo "The value of \$rc is: " . var_export($rc, true)."\r\n";

                            return $rc;
                        }
                        else
                        {
							
							//the query was not successfully executed
							
                            $e = oci_error($stid);

//                            echo "oci_execute() error: ".var_export($e, true)."\r\n";

                            //the SQL statement could not be executed:
                            if (isset($output_message))
                            {
//                                echo $output_message->add_message("The database statement could not be executed successfully");


//                                echo $output_message->add_message("oci_execute() error: ".var_export($e, true));
                            }
                            else
							{
//	                                echo "The database statement could not be executed successfully";
							}

                            //allow data conflict errors to not halt the program (currently being used in benthic image analysis script)
                            if ($e['code'] != 1)
                            {

                                if ($this->exit_on_failure)
                                {
                                    if (isset($output_message))
                                    {
                                        echo $output_message->add_message("halting script execution immdiately (query method)");
                                    }
									
                                    exit;
                                }
                            }


                        }
                    }
                }
                else
                {
//					echo "The query was not parsed successfully";

                    //the SQL statement could not be parsed:
                    if (isset($output_message))
                    {
//                        echo $output_message->add_message("The database statement could not be parsed");

                        $e = oci_error($this->conn);

//                        echo $output_message->add_message("oci_parse() error: ".var_export($e, true));
                    }
                    else
										{
//                        echo "The database statement could not be parsed";
										}

                    if ($this->exit_on_failure)
                    {
                        if (isset($output_message))
                        {
//                            echo $output_message->add_message("halting script execution immdiately (query method)");
                        }
                        exit;
                    }


                }
            }
            else
            {
                //the connection is NOT still active, exit the program and print the error:

                if (isset($output_message))
                {
//                    echo $output_message->add_message("The database connection was lost");

                    $e = oci_error($this->conn);

//                    echo $output_message->add_message("oci_parse() error: ".var_export($e, true));
                }
//                else
  //                  echo "The database connection was lost";


                if ($this->exit_on_failure)
                {
                    if (isset($output_message))
                    {
//                        echo $output_message->add_message("halting script execution immdiately (query method)");
                    }
                    exit;
                }

            }
			
			return $return_value;

        }


        //$returning_args is an array in the form:
        //  $returning_args['bind_name'] is an array containing bind variable names:
        //  $returning_args['values'] is an array containing the values to be assigned via the bind variables:
        //  $returning_args['data_type'] is an array containing bind variable types:
        //$return_vars is a reference variable array that will contain the LOB variables that are bound so the values can be set after the query is executed:
        function bind_values($stid, &$bind_array, &$return_id_exists, &$return_vars, $returning_args = array())
        {
            global $output_message;


//            echo "running bind_values(".var_export($bind_array, true)."\r\n";

//            echo "The value of \$returning_args is: " . var_export($returning_args, true)."\r\n";

            $return_id_exists = false;

            $continue = true;

            for ($i = 0; (($continue) && ($i < count($bind_array))); $i++)
            {
//                echo "bind the variable: " . $bind_array[$i][0]." with the value: " . var_export($bind_array[$i][1], true)."\r\n";

                //check if a :RETURN_ID placeholder has been used to return the new primary key value
                if ($bind_array[$i][0] == ":RETURN_ID")
                {
                    //the return id was found:
                    $return_id_exists = true;

                    $continue = oci_bind_by_name($stid, $bind_array[$i][0], $bind_array[$i][1], 32);
                }
                else
								{
										//check to see if there was a size parameter specified for the bind variable:
										if (isset($bind_array[$i][2]))	//the bind variable size parameter has been specified
                  		$continue = oci_bind_by_name($stid, $bind_array[$i][0], $bind_array[$i][1], $bind_array[$i][2]);
										else	//the bind variable size parameter has been specified
                  		$continue = oci_bind_by_name($stid, $bind_array[$i][0], $bind_array[$i][1]);

										//check if this is an OUT variable:
										if ((isset($bind_array[$i][3])) && ($bind_array[$i][3]))	//at least one OUT variable was found
                    	$return_id_exists = true;
								}
            }

            //initialize array for setting LOB values:
            $return_vars = array();


            //check if there are any $returning_args defined:
            if (!empty($returning_args))
            {
//                echo "\$returning_args is not empty, process the array variable";

                //$returning_args is not empty, process the array variable:

                //loop through the returning_args variable for all CLOB/BLOB values:
                for ($i = 0; (($continue) && ($i < count($returning_args['data_type']))); $i++)
                {
                    //check if this is a LOB data type:
                    if (($clob = ($returning_args['data_type'][$i] == "CLOB")) || ($returning_args['data_type'][$i] == "BLOB"))
                    {

                        //create the new variable of type LOB:
                        $return_vars[$i] = oci_new_descriptor($this->conn, OCI_D_LOB);

                        //depending on if the data type is a CLOB or BLOB bind the variable
                        $continue = oci_bind_by_name($stid, $returning_args['bind_name'][$i], $return_vars[$i], -1, ($clob ? OCI_B_CLOB : OCI_B_BLOB));
                    }
                    else
                    {
                        //this is not a LOB

//                        echo "This is not a LOB\r\n";

                        /*

                        $continue = false;

                        if (isset($output_message))
                            echo $output_message->add_message("The current returning variable was not a LOB, the query failed");
                        */
                    }
                }
            }


            //check if a bind operation failed:
            if (!$continue)
            {
                //a bind operation failed:

                if (isset($output_message))
                {
//                    echo $output_message->add_message("The database query failed");

                    $e = oci_error($stid);

                    $output_message->add_message("oci_bind_by_name() error: ".var_export($e, true));
                }
//                else
//                    echo "The database connection was lost";


                if ($this->exit_on_failure)
                {
                    if (isset($output_message))
                    {
                        $output_message->add_message("halting script execution immdiately (query method)");
                    }
                    exit;
                }
            }

            return $continue;
        }


        //this method returns the current result set row
        function fetch($stid, $mode = '')
        {
            $query_mode = (empty($mode) ? OCI_ASSOC+OCI_RETURN_NULLS: $mode);

            return oci_fetch_array($stid, $query_mode);
        }


        //function to generate a unique placeholder name and return it as a string
        function generate_placeholder ()
        {
            //generate the placeholder based on a three digit number with leading zeroes:
            return ":".str_pad($this->placeholder_counter ++, 3, "0", STR_PAD_LEFT);
        }


    }



?>
