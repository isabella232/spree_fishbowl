module Spree
  Variant.class_eval do
    include ActiveModel::Validations

    validates :sku, 'spree_fishbowl/sku_in_fishbowl' => true, :if => "sku.present?"

    alias_method :orig_on_hand, :on_hand
    alias_method :orig_on_hand=, :on_hand=

    def on_hand
      return orig_on_hand if (!SpreeFishbowl.enabled? || !sku)

      if Spree::Config[:track_inventory_levels] && !self.on_demand
        available = SpreeFishbowl.client_from_config.available_inventory(self)
        available.nil? ? orig_on_hand : available
      else
        (1.0 / 0) # Infinity
      end
    end

    def on_hand=(new_level)
      return orig_on_hand=(new_level) if !SpreeFishbowl.enabled?

      # no-op otherwise
    end

  end
end
