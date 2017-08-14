define mysql::iteration::user_iterator(
  $ensure,
  $user,
  $password_hash,
  $provider,
)
{

  $host = $title
  $user_host = "${user}@${host}"

  ensure_resource('mysql_user', $user_host,
    {
      ensure        => $ensure,
      password_hash => $password_hash,
      provider      => $provider,
    }
  )

  #anchor { 'mysql::iteration::user_iterator::begin': } ->
  #Mysql_User[$user_host] ->
  #anchor { 'mysql::iteration::user_iterator::end': }

}
