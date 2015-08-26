defmodule Arc.File do
  defstruct [:path, :file_name, :binary]

  def generate_temporary_path(file \\ nil) do
    extension = Path.extname((file && file.path) || "")

    file_name =
      :crypto.rand_bytes(20)
      |> Base.encode32()
      |> Kernel.<>(extension)

    Path.join(System.tmp_dir, file_name)
  end

  # Given a remote file
  def new(remote_path = "http" <> _) do
    case save_file(remote_path) do
      {:ok, local_path} -> %Arc.File{path: local_path, file_name: Path.basename(local_path)}
      :error -> {:error, :bad_remote_file}
    end
  end

  # Accepts a path
  def new(path) when is_binary(path) do
    case File.exists?(path) do
      true -> %Arc.File{path: path, file_name: Path.basename(path)}
      false -> {:error, :no_file}
    end
  end

  def new(%{filename: filename, binary: binary}) do
    %Arc.File{ binary: binary, file_name: Path.basename(filename) }
  end

  # Accepts a map conforming to %Plug.Upload{} syntax
  def new(%{filename: filename, path: path}) do
    case File.exists?(path) do
      true -> %Arc.File{path: path, file_name: filename}
      false -> {:error, :no_file}
    end
  end

  def ensure_path(file = %{path: path}) when is_binary(path), do: file
  def ensure_path(file = %{binary: binary}) when is_binary(binary), do: write_binary(file)

  defp write_binary(file) do
    path = generate_temporary_path(file)
    :ok = File.write!(path, file.binary)

    %__MODULE__{
      file_name: file.file_name,
      path: path
    }
  end

  defp save_file(remote_path) when is_binary(remote_path) do
    local_path =
      generate_temporary_path()
      |> Path.join(Path.basename(remote_path))

    case save_temp_file(local_path, remote_path) do
      :ok -> {:ok, local_path}
      _   -> :error
    end
  end

  defp save_temp_file(local_path, remote_path) do
    File.write(local_path, get_remote_file(remote_path))
  end

  defp get_remote_file(remote_path) do
    {:ok, {{'HTTP/1.1', _, _}, _, body}} =
      :httpc.request(:get, {String.to_char_list(remote_path), []}, [], [])

    body
  end
end
