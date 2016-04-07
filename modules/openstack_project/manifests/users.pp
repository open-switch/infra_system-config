# == Class: openstack_project::users
#
class openstack_project::users {
  # Make sure we have our UID/GID account minimums for dynamic users set higher
  # than we'll use for static assignments, so as to avoid future conflicts.
  include openstack_project::params
  file { '/etc/login.defs':
    ensure => present,
    source => $::openstack_project::params::login_defs,
  }
  User::Virtual::Localuser {
    require => File['/etc/login.defs']
  }

  @user::virtual::localuser { 'dompegam':
    realname => 'Diego Dompe',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDV7iwGBrjEh6IEpHN/eS2TrRySGi43+ZHsdtLs5GG0vzYsqSwCZgQB3XHmdQZ3MYkkEGx9fdqfhJ8kV9edeOjlA1TczVw1kwfOT3MjjWPvR2QVuFN9W45gMM3WrA0EQZGY4jM93CfMbby11xnJ1NvNcuWqG1qYwe9SNCJJaDmtVtN3jH3DpF7hr8ke8hH3YMOdsFjqJyP8LvuJKd3LI2ZD/V7tdu513oHqo8RATyMHuUtEE094q22J+fkYGPtSSSG2ctXFThJR74nTXfbNA7LG6TcnadOTOkmh4dqKzmRnao3gHyu/oGpQxkY7cL2gXnx9Fwyr0r4Sm7vXXzI3o7kd',
    key_id   => 'dompegam@Aleph1Linux',
    uid      => 2000,
    gid      => 2000,
  }

  @user::virtual::localuser { 'tiamarin':
    realname => 'Javier Tia',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEA67PRWQqWKFa0nguNgAJMbU6jR7LAUur0xgstqsCyDJPEoSyGEhULIp6HPU0vJNSjk+F/PjqBQGVWdQCEE04T4B5veZNeD9oFM2hBEMc4Ac1FsA4vVgYwT3AHoQxfsUxGTTFzzroqRFN0yICpgb1r1xfoafUYt1TCEpxqF6YqdEzutp4KEGxUK+nLVKzrZvRQUtgKSFjHHylMAOZcXl/SDHh42IpDGrVjqsBig9c9uQUWv1A4bj5cfBFNKvp9Z4p5AK+5CGNCNL19aLIPgQMNzGrIROff4hD5GJuqzJqtgIaCgsxnlU+62zI8LP6pArEgqY5nQUU8kwkIiV2FnDcqvGLafxrRyQDNeHldssNLawwphZg6wdAxnRZa6QXR7+AtbU9Rw0mWLH6eyTwQPET00jicCp2bvlf1+LmC8ANRClhY4qeaSE9/9IRdalHqh7hnVM48a+t8MpttBoo+puu71NdjKnSSTjHyrmrq5aX7Jubm/Ds+fC/LQlc6uXCavxmDTXB4RSaFrZjiXz6iavbt5dmNhdsHi6gjf/0kR8KGAJOCntT0a2h6LxMVQo1c+xrp6emtD5rbzFe/dzHqDtghDraRZEYcWXIGA32emEeSHUs67IauHUCUzgjDBafEP7EV7pECSfkHC/F2hz3e2Mz0vRfnyT2lfn8LRdhPzJz5D6M=',
    key_id   => 'javier.tia@hp.com',
    uid      => 2001,
    gid      => 2001,
  }

  @user::virtual::localuser { 'ying':
    realname => 'Ying Wang',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDYX/e38dceillWY4beLUhmX5B0KvnBVd4QktV/k8O/v3QVwNit8jOP8tyRbmDrn2IbQKWJWgu4YIzaumhYqMJ9Ooaa7ZOWwpI4/74Pduo3xgLYhohhd2wPKSC80GiP6gLUVQgI2cmJFCLoU5vxhr1KOcWWTlKFOWTwOzxXwDKAUd6CQy5HryCoqmJ1CwFBimu8e3WG13LfcbohTz3guu5vKrL98yCL9hefXEMCEh/pC4FezmChX/k0DT2QK+EquO4HjTt0WpM4udGpA46Da54Pq1P6Csu/VOoYKu+k1OsKZMujO9DOTF4aXFPVO/vVrGygaKwZxWu3Bt9dDW3m+/WP',
    key_id   => 'ying.wang11@hpe.com',
    uid      => 2002,
    gid      => 2002,
  }

  @user::virtual::localuser { 'marisidd':
    realname => 'Basavaraju Marisiddaiah',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAwkDK+OWmRGfjjCv9LUsz10UTeRI5GXQ+MeAZpYNNZoJxbKL80qVwBVJ42Ip/g/yXwxt4KvuxTuwCg/T0tjiAGoTa/PHvKfYI0/MrIA2TF+f+Ig7OBwAClGTgOz7PUbaZYAqR8A6oy8gJB5cka2DDOfi0KBkfTZwNjb3nUR8lJMCoeGfH9ODWDJMkesPmkHZOLdlm7rAfDY+WN00PbbL6yYv68TfIp4TyB2tbq9l3wE3pK18fkluvul3I0Urgxgfi1/qiL9ajkWXe7ZhoGl6fnsPhoD+UsrhFkcwISHJcug3PC0rJydOTMhT5hnfxOvOgsutaju+uLLawRpZ9Jzv1+w',
    key_id   => 'basavaraju.marisiddaiah@hpe.com',
    uid      => 2003,
    gid      => 2003,
  }
  
  @user::virtual::localuser { 'marisidd':
    realname => 'Basavaraju Marisiddaiah',
    sshkeys  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA1W4pd6GCMWtqXFH1//u0fdvuKA+pYTP+7NwSXoYPsbU5kMSvapLrDTxxJaDpN2sn7mICq7YB9mQEHKfegkNTNOdaD4yEUvWySwmBStvF7CA+02nk336/FvTyAzYInVr7l5T1VWvOpn8FpKDZZzNYeiX8Z2C9wYgYd5ZMZOUHzHg4ULs69KXwH0WmhAiWtT0mZVbjK9RHq1QoFsauuDDSVGJRv5VK71CesGyQV0mvuwqJy/uiKfC9IfUUxkVa/0P97QfqfEKASVtB3Q3tcmxCHTOhBh1hpauw9cpq4Q65iAYf0/CtWGSP5R3ngv1B1aQPwI19mcKB2tL85f386iDC/Q',
    key_id   => 'ankit.sinha@hpe.com',
    uid      => 2004,
    gid      => 2004,
  }
}

}

