defmodule Bench do
  defmodule GitLoadSave do
    @file_name "benchee.run"

    def config(branch \\ "master") do
      case load(branch) do
        nil -> [save: save()]
        load -> [load: load, save: save()]
      end
    end

    defp load(branch \\ "master") do
      case branch == branch() do
        true ->
          nil

        false ->
          System.tmp_dir!()
          |> Path.join(app())
          |> Path.join(branch)
          |> Path.join(@file_name)
      end
    end

    defp save do
      tag = branch()

      path =
        System.tmp_dir!()
        |> Path.join(app())
        |> Path.join(tag)
        |> Path.join(@file_name)

      [path: path, tag: tag]
    end

    defp app, do: to_string(Mix.Project.config()[:app])

    defp branch,
      do:
        "git"
        |> System.cmd(["rev-parse", "--abbrev-ref", "HEAD"])
        |> trim()

    defp trim({str, 0}), do: String.trim(str)
  end

  def fun do
    schema =
      Xema.new(
        {:map,
         definitions: %{
           neg: {:integer, maximum: 0},
           pos: {:integer, minimum: 0}
         },
         properties: %{
           neg: {:ref, "#/definitions/neg"},
           pos: {:ref, "#/definitions/pos"}
         }}
      )

    data = %{neg: -5, pos: 6}

    fn -> true = Xema.valid?(schema, data) end
  end

  def run do
    config =
      [
        parallel: 4,
        print: [fast_warning: false],
        formatters: [
          Benchee.Formatters.Console
        ]
      ] ++ GitLoadSave.config()

    Benchee.run(
      %{"ref" => fun()},
      config
    )
  end
end

Bench.run()
