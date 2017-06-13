define mysql::user_wrapper(
  $user,
  $user_resource,
  $dbname,
  $grant,
  $table,
  $ensure = present,
) {

  $host = $name

  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${name}",
      table      => $table,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
      ],
    }
  }

}
