package wireclient

import (
	"github.com/google/wire"

	"github.com/bersennaidoo/microdataservice/transport/rpc/stats"
)

// Inject produces a wire.ProviderSet with our RPC clients
var Inject = wire.NewSet(
	stats.NewStatsServiceJSONClient,
)
