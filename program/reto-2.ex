defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))
    {:error, "Pasa1"}
    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        {:error, "Pasa"}
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end


  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def search_books_by_title(library, query) do
    Enum.filter(library, fn book ->
      String.contains?(String.downcase(book.title), String.downcase(query))
    end)
  end

  def delete_book(library, isbn) do
    Enum.filter(library, fn book -> book.isbn != isbn end)
  end

  def run do
    library = []
    users = []
    loop(library, users)
  end

  defp loop(library, users) do
    IO.puts("""
    Biblioteca
    1. Agregar Libro
    2. Agregar Usuario
    3. Prestar Libro
    4. Devolver Libro
    5. Listar Libros
    6. Listar Usuarios
    7. Libros Prestados por Usuario
    8. Buscar Libro por Título
    9. Eliminar Libro
    10. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el título del libro: ")
        title = IO.gets("") |> String.trim()
        IO.write("Ingrese el autor del libro: ")
        author = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()
        book = %Book{title: title, author: author, isbn: isbn}
        library = add_book(library, book)
        loop(library, users)

      2 ->
        IO.write("Ingrese el nombre del usuario: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim()
        user = %User{name: name, id: id}
        users = add_user(users, user)
        loop(library, users)

      3 ->
        IO.write("Ingrese el ID del usuario: ")
        user_id = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()
        case borrow_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            library = updated_library
            users = updated_users
            IO.puts("Libro prestado exitosamente.")
          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end
        loop(library, users)

      4 ->
        IO.write("Ingrese el ID del usuario: ")
        user_id = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()
        case return_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            library = updated_library
            users = updated_users
            IO.puts("Libro devuelto exitosamente.")
          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end
        loop(library, users)

      5 ->
        IO.puts("Lista de libros:")
        Enum.each(library, fn book ->
          IO.puts("#{book.title} por #{book.author} (ISBN: #{book.isbn}) [#{if book.available, do: "Disponible", else: "Prestado"}]")
        end)
        loop(library, users)

      6 ->
        IO.puts("Lista de usuarios:")
        Enum.each(users, fn user ->
          IO.puts("#{user.name} (ID: #{user.id})")
        end)
        loop(library, users)

      7 ->
        IO.write("Ingrese el ID del usuario: ")
        user_id = IO.gets("") |> String.trim()
        IO.puts("Libros prestados por el usuario:")
        Enum.each(books_borrowed_by_user(users, user_id), fn book ->
          IO.puts("#{book.title} por #{book.author} (ISBN: #{book.isbn})")
        end)
        loop(library, users)

      8 ->
        IO.write("Ingrese el título a buscar: ")
        query = IO.gets("") |> String.trim()
        results = search_books_by_title(library, query)
        IO.puts("Resultados de la búsqueda:")
        Enum.each(results, fn book ->
          IO.puts("#{book.title} por #{book.author} (ISBN: #{book.isbn}) [#{if book.available, do: "Disponible", else: "Prestado"}]")
        end)
        loop(library, users)

      9 ->
        IO.write("Ingrese el ISBN del libro a eliminar: ")
        isbn = IO.gets("") |> String.trim()
        library = delete_book(library, isbn)
        IO.puts("Libro eliminado con exito.")
        loop(library, users)


      10 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(library, users)
    end
  end
end

# Ejecutar el gestor de la biblioteca
Library.run()
