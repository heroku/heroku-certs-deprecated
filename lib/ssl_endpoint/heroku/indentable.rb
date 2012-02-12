module Heroku::Indentable

  def display_indented(str)
    @indent_size ||= 0
    display " " * @indent_size + str
  end

  def indent(size)
    @indent_size ||= 0
    @indent_size += size
    yield
    @indent_size -= size
  end

end
