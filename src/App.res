%%raw(`import './App.css';`)

@module("./logo.svg") external logo: string = "default"

module Response = {
  type t<'data>
  @send external json: t<'data> => Promise.t<'data> = "json"
}

module User = {
  type t = {id: int, name: string}

  // @scope("globalThis")
  @val
  external fetch: (string, 'params) => Promise.t<Response.t<Js.Nullable.t<array<t>>>> = "fetch"

  // ~token: string
  let getUsers = () => {
    open Promise

    let params = {
      // "Authorization": `Bearer ${token}`
      "X-RESCRIPT": true,
    }

    fetch("https://jsonplaceholder.typicode.com/users", params)
    ->then(res => {
      res->Response.json
    })
    ->then(data => {
      let ret = switch Js.Nullable.toOption(data) {
      | Some(data) => data
      | None => []
      }
      Ok(ret)->resolve
    })
    ->catch(e => {
      let msg = switch e {
      | JsError(err) =>
        switch Js.Exn.message(err) {
        | Some(msg) => msg
        | None => ""
        }
      | _ => "Unexpected error occurred"
      }
      Error(msg)->resolve
    })
  }
}

exception FailedRequest(string)

type state = Empty | Loading | Done
@react.component
let make = () => {
  let (users, setUsers) = React.useState((_): array<User.t> => [])
  let (state, setState) = React.useState(_ => Empty)

  React.useEffect1(() => {
    open Promise

    setState(_ => Loading)

    let _ =
      User.getUsers()
      ->then(result => {
        switch result {
        | Ok(users) =>
          setUsers(_ => users)
          setState(_ => Done)
          Js.log("\nAvalilable Users:\n---")
          Belt.Array.forEach(users, u => {
            Js.log(`${Belt.Int.toString(u.id)} - ${u.name}`)
          })
        | Error(msg) => Js.log("Could not query products: " ++ msg)
        }->resolve
      })
      ->catch(e => {
        switch e {
        | FailedRequest(msg) => Js.log("Operation failed! " ++ msg)
        | _ => Js.log("Unknown error")
        }
        resolve()
      })

    None
  }, [])

  let content = Belt.Array.mapWithIndex(users, (i, user) => {
    <li key={Belt.Int.toString(i)}> {React.string(user.name)} </li>
  })->React.array

  <div className="App">
    <header className="App-header">
      <img src={%raw("logo")} className="App-logo" alt="logo" />
      <p>
        {React.string("Edit ")}
        <code> {React.string("src/App.js")} </code>
        {React.string(" and save to reload.")}
      </p>
      {state === Loading ? <p> {React.string("loading...")} </p> : React.null}
      <ul> {content} </ul>
      <a className="App-link" href="https://reactjs.org" target="_blank" rel="noopener noreferrer">
        {React.string("Learn React")}
      </a>
    </header>
  </div>
}
