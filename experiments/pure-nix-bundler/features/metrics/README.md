# Buffer fixture

Attaches once to each Markdown buffer and requests an initial update. `TextChanged`
requests replace older work. Tests manually deliver asynchronous replies to cover
out-of-order completion, failed cancellation and results arriving after disposal.
No external process, debounce, timeout, or automatic hot reload is implemented.
