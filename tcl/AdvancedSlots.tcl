::nx::Slot method type=choice {name value arg} {
  if {$value ni [split $arg |]} {
    error "Value '$value' of parameter $name not in permissible values $arg"
  }
}
