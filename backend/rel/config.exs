Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"b[0GIkF=51kr<7Sx?[8/s(G/iLkt)_dkKUL!>l>U_6SS4,lwcaLD<gw0Ksz*`N?u"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"1{Nk0}!/i=c=[L@VjAjXT&`0[4FZXd~OeOF50Gvx!Je;]ic:4pi<*%p@6~e~.7j`"
end

release :commies do
  set version: current_version(:commies)
  set commands: [
    migrate: "rel/commands/migrate.sh"
  ]
end
