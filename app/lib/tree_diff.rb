# @see https://gitlab.com/mcnelson/tree_diff/-/blob/master/lib/tree_diff.rb
# @see https://gitlab.com/mcnelson/tree_diff

class TreeDiff
  # A container for each copied attribute from the source object by each path.
  Mold = Class.new

  class Change
    attr_reader :path, :old, :new, :current_object

    def initialize(path, old, new)
      @path = path
      @old = old
      @new = new
    end
  end

  # Defines the full tree of relationships and attributes this TreeDiff class observes. Pass a structure of arrays and
  # hashes, similar to a strong_params `#permit` definition.
  #
  # ```
  # class MyDiffClass < TreeDiff
  #   observe :order_number, :available_at, line_items: [:description, :price, tags: [:name]]
  # end
  # ```
  #
  # @param [Array] defs Observation attribute definitions. Anything not in this list will be skipped by the diff.
  # @return [void]
  def self.observe(*defs)
    class_variable_set(:@@observations, defs)
    class_variable_set(:@@attribute_paths, [])
    observe_chain [], defs
  end

  # Adds a condition to an attribute that dictates whether an attribute is compared. The given block is invoked
  # just before trying to call the attribute to get a comparable value. Called twice per attribute, once for the
  # old value and once for the new.
  #
  # @yieldparam original_object The original object being compared.
  # @yieldreturn [Boolean] Whether this attribute should be compared.
  #
  # ```
  # class MyDiffClass < TreeDiff
  #   observe details: :order_status
  #
  #   condition [:details, :order_status] do |order|
  #     order.order_status == 'delivered'
  #   end
  # end
  #
  # @return [void]
  def self.condition(path, &condition)
    class_variable_set(:@@conditions, []) unless class_variable_defined?(:@@conditions)
    c = class_variable_get(:@@conditions)
    c << [path, condition]
    class_variable_set(:@@conditions, c)
  end

  # Holds the original object tree definitions passed to `.observe`.
  # @return [Array]
  def self.observations
    class_variable_set(:@@observations, nil) unless class_variable_defined?(:@@observations)
    class_variable_get(:@@observations)
  end

  # All paths to be walked expressed as arrays, ending in each observed attribute. These are generated upon
  # calling `.observe`.
  # @return [Array]
  def self.attribute_paths
    class_variable_set(:@@attribute_paths, nil) unless class_variable_defined?(:@@attribute_paths)
    class_variable_get(:@@attribute_paths)
  end

  # All conditions defined via `.condition`.
  # @return [Array]
  def self.conditions
    class_variable_set(:@@conditions, []) unless class_variable_defined?(:@@conditions)
    class_variable_get(:@@conditions)
  end

  def self.observe_chain(chain, attributes)
    attributes.each do |method_name|
      if method_name.respond_to?(:keys)
        method_name.each do |child_method, child_attributes|
          observe_chain chain + [child_method], keep_as_array(child_attributes)
        end
      else
        attribute_paths << chain + [method_name]
      end
    end
  end
  private_class_method :observe_chain

  def self.keep_as_array(input)
    input.is_a?(Array) ? input : [input]
  end
  private_class_method :keep_as_array

  # Prepares a new comparision. Creates a mold/mock of the object being diffed as the 'old' state according to the
  # relationship tree defined via `.observe`.  Each attribute's value is copied via serializing and deserializing
  # via Marshal.
  #
  # @param original_object The object to be compared, before you mutate any of its attributes.
  def initialize(original_object)
    check_observations

    @old_object_as_mold = create_mold Mold.new, original_object, self.class.observations
    @current_object = original_object
  end

  # Check if there is any change at all, otherwise each observed attribute is considered equal before and after
  # the change.
  # @return [Boolean] Whether there was a change
  def saw_any_change?
    changes.present?
  end

  # Walk all observed paths and compare each resulting value. Returns a structure like:
  #
  # ```ruby
  #   [{path: [:line_items, :description], old: ["thing", "other thing"], new: ["other thing", "new thing"]},
  #    {path: [:line_items, :price_usd_cents], old: [1234, 5678], new: [5678, 1357]},
  #    {path: [:line_items, :item_categories, :description], old: ['foo', 'bar'], new: ['foo']}]
  # ```
  #
  # @return [Array] A list of each attribute that has changed. Each element is a hash with keys
  #                 :path, :old, and :new.
  def changes
    iterate_observations(@old_object_as_mold, @current_object)
  end

  # Compare all observed paths, find the given path, and check if its value has changed.
  #
  # @return [Boolean] Whether the path is changed.
  def changed?(path)
    changes_at(path).present?
  end

  # Walk all observed paths and compare each resulting value. Returns a structure like:
  #
  # @example Return all "old" values
  #   diff = MyDiffClass.new(my_object)
  #   # Mutate the object...
  #   changes = diff.changes_as_objects
  #
  #   changes.map(&:old)
  #
  # @return [Array of TreeDiff::Change] A list of each attribute that has changed. Each element is an ojbect with
  #                                     methods :path, :old, and :new.
  def changes_as_objects
    changes.map { |c| Change.new(c.fetch(:path), c.fetch(:old), c.fetch(:new)) }
  end

  # Get a collection of changed paths only.
  # @return [Array of Arrays]
  def changed_paths
    changes_as_objects.map(&:path)
  end

  # Find a change by its path.
  #
  # @return [TreeDiff::Change] The change at the given path, or `nil` if no change.
  def changes_at(path)
    arrayed_path = Array(path)
    changes_as_objects.detect { |c| c.path == arrayed_path }
  end

  private

  def check_observations
    if self.class == TreeDiff
      raise 'TreeDiff is an abstract class - write a child class with observations'
    end

    if !self.class.observations || self.class.observations.empty?
      raise 'you need to define some observations first'
    end
  end

  def create_mold(mold, source_object, attributes)
    attributes.each do |attribute|
      if attribute.respond_to?(:keys)
        attribute.each do |attribute_name, child_attributes|
          mold_or_molds = mold_relationship(source_object, attribute_name, child_attributes)
          mold.define_singleton_method(attribute_name) { mold_or_molds }
        end
      else
        mold.define_singleton_method(attribute, &call_and_copy_value(source_object, attribute))
      end
    end

    mold
  end

  def mold_relationship(source_object, relationship_name, relationship_attributes)
    source_value = source_object.public_send(relationship_name)
    relationship_attributes = [relationship_attributes] unless relationship_attributes.is_a?(Array)

    if source_value.respond_to?(:each) # 1:many
      source_value.map do |v|
        create_mold(Mold.new, v, relationship_attributes)
      end
    else # 1:1
      create_mold(Mold.new, source_value, relationship_attributes)
    end
  end

  def call_and_copy_value(receiver, method_name)
    return -> { nil } unless receiver

    source_value = receiver.public_send(method_name)
    source_value = Marshal.load(Marshal.dump(source_value)) # Properly clones hashes

    -> { source_value } # The return value of this becomes the body of the method defined on the Mold object
  end

  def iterate_observations(mold, current_object)
    self.class.attribute_paths.each.with_object([]) do |path, changes|
      old_obj_and_method = try_path mold, path
      new_obj_and_method = try_path current_object, path, mold

      old_value = call_method_on_object(old_obj_and_method, path)
      new_value = call_method_on_object(new_obj_and_method, path)

      changes << { path: path, old: old_value, new: new_value } if old_value != new_value
    end
  end

  def call_method_on_object(object_and_method, path)
    callable = method_caller_with_condition(path)

    if object_and_method.is_a?(Array)
      # TODO: Flatten is kind of a hack? Revisit this..
      object_and_method.flatten.each.with_object([]) do |r, c|
        result = callable.(r)
        c << result if result
      end
    else
      result = callable.(object_and_method)
      result
    end
  end

  def method_caller_with_condition(path)
    ->(object_and_method) do
      return nil unless object_and_method.fetch(:receiver)

      condition = condition_for(path)

      if !condition || condition.call(object_and_method.fetch(:receiver))
        object_and_method.fetch(:receiver).public_send(object_and_method.fetch(:method_name))
      end
    end
  end

  def condition_for(path)
    return unless (condition = self.class.conditions.detect { |c| c.first == path })

    condition.last # A stored block (proc)
  end


  # By design this tries to be as loosely typed and flexible as possible. Sometimes, calling an attribute
  # name on a collection of them yields an enumerable object. For example, active record's enum column returns
  # a hash indicating the enumeration definition. That would lead to incorrectly comparing this value, a hash,
  # rather than the actual data point in each item of the collection.
  #
  # I overcome this by passing the mold, or the original object, as a reference, and following each result of
  # the call chain on not only the changed/current object, but that original object too. The mold is created
  # with correct 1:many relationships and does not have the aforementioned problem, so by verifying the path
  # against the mold first, we avoid that issue.
  def try_path(receiver, path, mold_as_reference = nil)
    result, reference_result = follow_call_chain(receiver, path, mold_as_reference)

    if result.respond_to?(:each)
      result.map.with_index do |o, idx|
        ref = reference_result[idx] if reference_result
        try_path(o, path[1..-1], ref)
      end
    else
      { receiver: result, method_name: path.last }
    end
  end

  # Execute the call chain given by path. i.e. [:method, :foo, :bar] until just before the last method
  def follow_call_chain(receiver, chain, reference)
    chain[0...-1].each do |method_name|
      if receiver.respond_to?(method_name) && (!reference || reference.respond_to?(method_name))
        receiver = receiver.public_send(method_name)
        reference = reference.public_send(method_name) if reference
      end
    end

    [receiver, reference]
  end
end
