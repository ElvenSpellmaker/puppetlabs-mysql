# See README.md for details.
define mysql::db (
  $user,
  $password,
  $dbname         = $name,
  $charset        = 'utf8',
  $collate        = 'utf8_general_ci',
  $host           = 'localhost',
  $grant          = 'ALL',
  $enforce_sql    = false,
  $ensure         = 'present',
  $import_timeout = 300,
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${dbname}.*"

  include '::mysql::client'

  anchor{"mysql::db_${name}::begin": }->
  Class['::mysql::client']->
  anchor{"mysql::db_${name}::end": }

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [ Class['mysql::client'] ],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql',
  }

  ensure_resource('mysql::user_wrapper', $host,
    {
      ensure        => $ensure,
      user          => $user,
      user_resource => $user_resource,
      dbname        => $dbname,
      grant         => $grant,
      table         => $table,
    }
  )

}
