define mysql::iteration::grant_iterator(
  $user,
  $privileges,
  $provider,
  $table,
)
{

  $host = $title

  $user_host = "${user}@${host}"
  mysql_grant { "${user_host}/${table}":
    privileges => $grant,
    provider   => 'mysql',
    user       => $user_host,
    table      => $table,
    require    => [
      Mysql_database[$dbname],
      Mysql_user[$user_host],
    ],
  }

}
