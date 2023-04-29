public class CommunitySettings 
{
    public CommunitySettings(string communityName) 
    {
		List<Network> networks = [	SELECT Id, Name, UrlPathPrefix 
									FROM Network 
									WHERE Name = :communityName ];

        networkId = networks.size() == 0 ? '' : networks[0].Id;
        networkpath = networks.size() == 0 ? '' : networks[0].UrlPathPrefix;
        networkName = networks.size() == 0 ? '' : networks[0].Name;
    }

    public CommunitySettings() 
    {
		Id theNetworkId = Network.getNetworkId();
		List<Network> networks = new List<Network>();

		if(networkId != null)
		{
			networks = [	SELECT Id, Name, UrlPathPrefix 
							FROM Network 
							WHERE Id = :theNetworkId ];
		}

        networkId = networks.size() == 0 ? '' : networks[0].Id;
        networkpath = networks.size() == 0 ? '' : networks[0].UrlPathPrefix;
        networkName = networks.size() == 0 ? '' : networks[0].Name;

    }

    public string networkId { get; set; }
    public string networkPath { get; set; }
    public string networkName { get; set; }
}