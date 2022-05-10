%%raw(`import './App.css';`)

@module("./logo.svg") external logo: string = "default"

@react.component
let make = () => {
  <div className="App">
    <header className="App-header">
      <img src={%raw("logo")} className="App-logo" alt="logo" />
      <p>
        {React.string("Edit ")}
        <code> {React.string("src/App.js")} </code>
        {React.string(" and save to reload.")}
      </p>
      <a className="App-link" href="https://reactjs.org" target="_blank" rel="noopener noreferrer">
        {React.string("Learn React")}
      </a>
    </header>
  </div>
}

module Response = {
  type t<'data>
  @send external json: t<'data> => Promise.t<'data> = "json"
}

module Product = {
  type t = {id: int}

  // @scope("globalThis")
  @val
  external fetch: (string, 'params) => Promise.t<Response.t<{"resp_data": Js.Nullable.t<array<t>>}>> =
    "fetch"

  // ~token: string
  let getProducts = (()) => {
    open Promise

    let params = {
      // "Authorization": `Bearer ${token}`
      "X-RESCRIPT": true,
    }
 
    fetch("https://api.zsxq.com/v2/starry_sky/questions/sticky_questions", params)
    ->then(res => {
      res->Response.json
    })
    ->then(data => {
      let ret = switch Js.Nullable.toOption(data["resp_data"]) {
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
