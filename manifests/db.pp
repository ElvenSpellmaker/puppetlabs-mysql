# See README.md for details.
define mysql::db (
  $user,
  $password,
  $dbname                                     = $name,
  $charset                                    = 'utf8',
  $collate                                    = 'utf8_general_ci',
  $host                                       = 'localhost',
  $grant                                      = 'ALL',
  $sql                                        = undef,
  $enforce_sql                                = false,
  $ensure                                     = 'present',
  $import_timeout                             = 300,
  $import_cat_cmd                             = 'cat',
) {
  #input validation
  $table = "${dbname}.*"

  $sql_inputs = join([$sql], ' ')

  include '::mysql::client'

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [ Class['mysql::client'] ],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $hosts = is_array($host) ? {
    true    => $host,
    default => [$host],
  }

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql',
    user          => $user,
  }
  ensure_resource('mysql::iteration::user_iterator', $hosts, $user_resource)

  if $ensure == 'present' {
    mysql::iteration::grant_iterator { $hosts:
      user       => $user,
      privileges => $grant,
      provider   => 'mysql',
      table      => $table,
    }
    /*mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
      ],
    }*/

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${dbname}-import":
        command     => "${import_cat_cmd} ${sql_inputs} | mysql ${dbname}",
        logoutput   => true,
        environment => "HOME=${::root_home}",
        refreshonly => $refresh,
        path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        require     => Mysql_grant[$hosts],
        subscribe   => Mysql_database[$dbname],
        timeout     => $import_timeout,
      }
    }
  }
}
