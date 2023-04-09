ExUnit.configure(exclude: [skip: true])
ExUnit.start()

Application.put_env(:awex, :request_options, [follow_redirect: true])
