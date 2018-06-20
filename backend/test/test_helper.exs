Application.load(:commies)

:commies
|> Application.spec(:applications)
|> Enum.each(&Application.ensure_all_started/1)

ExUnit.start()
