require 'rails_helper'

RSpec.describe UserResource, type: :resource do
  describe 'serialization' do
    let!(:user) { create(:user) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(user.id)
      expect(data.jsonapi_type).to eq('users')
    end
  end

  describe 'filtering' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: user2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([user2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:user1) { create(:user, email: 'a@houseninja.co') }
      let!(:user2) { create(:user, email: 'b@houseninja.co') }

      context 'when ascending' do
        before do
          params[:sort] = 'email'
        end

        it 'works' do
          render
          expect(d.map(&:email)).to eq([
            user1.email,
            user2.email
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-email'
        end

        xit 'works' do
          render
          expect(d.map(&:email)).to eq([
            user2.email,
            user1.email
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    describe 'property' do
      let!(:user) { create(:user) }
      let!(:property) { create(:property, user: user) }

      before do
        params[:include] = 'properties'
      end

      it 'sideloads user properties' do
        render
        a = d[0].sideload(:properties)[0]
        expect(a.jsonapi_type).to eq('properties')
        expect(a.id).to eq(property.id)
      end
    end
  end
end
