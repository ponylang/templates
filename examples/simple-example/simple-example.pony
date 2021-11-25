// in your code this `use` statement would be:
// use "templates"
use "../../templates"

actor Main
  new create(env: Env) =>
    env.out.print("we need at least 1 example. this one does nothing yet. want to contribute one?")
