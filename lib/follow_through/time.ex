defmodule FollowThrough.Time do
  @callback weekday(Timex.Types.valid_datetime()) ::
              Timex.Types.weekday() | {:error, term()}
end
