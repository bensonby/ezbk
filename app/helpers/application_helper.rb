module ApplicationHelper
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association, options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  end

  def sanitized_object_name(object_name)
    object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/,"_").sub(/_$/,"")
  end
 
  def sanitized_method_name(method_name)
    method_name.sub(/\?$/, "")
  end
 
  def form_tag_id(object_name, method_name)
    "#{sanitized_object_name(object_name.to_s)}_#{sanitized_method_name(method_name.to_s)}"
  end

  def currency_format(amount)
    number_with_precision(amount, :precision => 2, :delimiter => ',')
  end

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  def edit_icon
    image_tag("page_edit.png", :size => '16x16', :alt => 'Edit', :title => 'Edit') #+ "Edit"
  end

  def destroy_icon
    image_tag("page_delete.png", :size => '16x16', :alt => 'Delete', :title => 'Delete') #+ "Delete"
  end
end
