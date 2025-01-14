RSpec.describe "databases" do
  let(:access_token) { "foo-1234" }
  subject(:client) { Notion::Client.new(token: access_token) }

  let(:database_id) { "abcd-database-1234" }
  let(:get_database_fixture) { load_fixture("databases/200_get_database") }
  let(:get_databases_fixture) { load_fixture("databases/200_get_databases") }
  let(:query_database_fixture) { load_fixture("databases/200_query_database") }

  before do
    stub_request(:get, "https://api.notion.com/v1/databases/#{database_id}")
      .to_return(body: get_database_fixture)

    stub_request(:get, "https://api.notion.com/v1/databases")
      .to_return(body: get_databases_fixture)

    stub_request(:post, "https://api.notion.com/v1/databases/#{database_id}/query")
      .to_return(body: query_database_fixture)
  end

  describe "databases#retrieve" do
    it "should call GET api.notion /databases" do
      client.databases.retrieve(database_id)

      expect(a_request(:get, "https://api.notion.com/v1/databases/#{database_id}"))
        .to have_been_made.once
    end

    it "should match fixture response" do
      expect(client.databases.retrieve(database_id).parsed_response).to eq(get_database_fixture)
    end
  end

  describe "databases#list" do
    it "should call GET api.notion /databases" do
      client.databases.list

      expect(a_request(:get, "https://api.notion.com/v1/databases"))
        .to have_been_made.once
    end

    it "should match fixture response" do
      expect(client.databases.list.parsed_response).to eq(get_databases_fixture)
    end
  end

  describe "databases#query" do
    let(:body) do
      {
        filter: {
          or: [
            {
              property: "In stock",
              checkbox: {
                equals: true
              }
            },
            {
              property: "Cost of next trip",
              number: {
                greater_than_or_equal_to: 2
              }
            }
          ]
        },
        sorts: [
          {
            property: "Last ordered",
            direction: "ascending"
          }
        ]
      }
    end

    it "should call POST api.notion /databases/{id}/query" do
      client.databases.query(database_id, body)

      expect(a_request(:post, "https://api.notion.com/v1/databases/#{database_id}/query")
        .with(body: body))
        .to have_been_made.once
    end

    it "should match fixture response" do
      expect(client.databases.query(database_id, body).parsed_response).to eq(query_database_fixture)
    end
  end
end
