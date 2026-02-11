# frozen_string_literal: true

require "rails_helper"

RSpec.describe Service::GetZoteroPublicationCountPresenter do
  let(:reserve_id) { "12345" }
  let(:getter) { class_double("HttpGetter") }

  def response_double(success:, body: "{}", headers: {})
    HttpGetter::Response.new("success?": success, body: body, headers: headers)
  end

  describe "#fetch_reserve" do
    context "when reserve name and publication count are available" do
      it "returns the name and pub_count" do
        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          body: { "data" => { "name" => "Reserve Name" } }.to_json,
        ))

        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}/items/top",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          headers: { "total-results" => "99" },
        ))

        presenter = Service::GetZoteroPublicationCountPresenter.new(getter, reserve_id: reserve_id)

        expect(presenter.fetch_reserve).to eq({ name: "Reserve Name", pub_count: "99" })
      end
    end

    context "when reserve name is present but pub_count request is unsuccessful" do
      it "returns the name with nil pub_count" do
        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          body: { "data" => { "name" => "Only Name" } }.to_json,
        ))

        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}/items/top",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(success: false))

        presenter = Service::GetZoteroPublicationCountPresenter.new(getter, reserve_id: reserve_id)

        expect(presenter.fetch_reserve).to eq({ name: "Only Name", pub_count: nil })
      end
    end

    context "when reserve name is unsuccessful but pub_count request is present" do
      it "returns the name with nil pub_count" do
        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(success: false))

        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}/items/top",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          headers: { "total-results" => "99" },
        ))

        presenter = Service::GetZoteroPublicationCountPresenter.new(getter, reserve_id: reserve_id)

        expect(presenter.fetch_reserve).to eq({ name: nil, pub_count: "99" })
      end
    end

    context "when pub_count lookup raises a connection error" do
      it "returns the name with nil pub_count" do
        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          body: { "data" => { "name" => "Name Present" } }.to_json,
        ))

        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}/items/top",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_raise(HttpGetter::ConnectionError.new("connection failed"))

        presenter = Service::GetZoteroPublicationCountPresenter.new(getter, reserve_id: reserve_id)

        expect(presenter.fetch_reserve).to eq({ name: "Name Present", pub_count: nil })
      end
    end

    context "when name lookup raises a connection error" do
      it "returns the name with nil pub_count" do
        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_raise(HttpGetter::ConnectionError.new("connection failed"))

        allow(getter).to receive(:get).with(
          url: "https://api.zotero.org/groups/#{reserve_id}/items/top",
          headers: Service::GetZoteroPublicationCountPresenter::HEADERS,
        ).and_return(response_double(
          success: true,
          headers: { "total-results" => "99" },
        ))

        presenter = Service::GetZoteroPublicationCountPresenter.new(getter, reserve_id: reserve_id)

        expect(presenter.fetch_reserve).to eq({ name: nil, pub_count: "99" })
      end
    end
  end
end
