require 'rails_helper'

RSpec.describe HomeCareTipResource, type: :resource do
  describe 'serialization' do
    let!(:home_care_tip) { create(:home_care_tip) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(home_care_tip.id)
      expect(data.jsonapi_type).to eq('home-care-tips')
    end
  end

  describe 'filtering' do
    let!(:home_care_tip1) { create(:home_care_tip, label: "tip 1") }
    let!(:home_care_tip2) { create(:home_care_tip, label: "tip 2") }

    context 'by label' do
      before do
        params[:filter] = { label: { eq: home_care_tip2.label } }
      end

      it 'works' do
        render
        expect(d.map(&:label)).to eq([home_care_tip2.label])
      end
    end
  end

  describe 'sorting' do
    describe 'by label' do
      let!(:home_care_tip1) { create(:home_care_tip, label: "tip 1") }
      let!(:home_care_tip2) { create(:home_care_tip, label: "tip 2") }

      context 'when ascending' do
        before do
          params[:sort] = 'label'
        end

        it 'works' do
          render
          expect(d.map(&:label)).to eq([
            home_care_tip1.label,
            home_care_tip2.label
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-label'
        end

        it 'works' do
          render
          expect(d.map(&:label)).to eq([
            home_care_tip2.label,
            home_care_tip1.label
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
